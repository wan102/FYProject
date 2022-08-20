import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/comment.dart';

class CommentsController extends GetxController with StateMixin<List<Comment>> {
  final _supabase = Get.find<SupabaseClient>();
  String placeId;

  late RealtimeSubscription subscription;
  CommentsController(this.placeId){
    fetchComments();
    // TODO Error when listening to realtime events
    // https://github.com/supabase-community/supabase-flutter/issues/81
    //listenCommentsChange();
  }

  fetchComments() async {
    final res = await _supabase
        .from('place_comment')
        .select("""
          *,
          user (
              name
          )
        """)
        .eq('place_id', placeId)
        .order("created_at", ascending: false)
        .execute();

    if(res.error != null) {
      final error = res.error;
      change(null, status: RxStatus.error(error.toString()));
      return;
    }

    var comments = <Comment>[];
    final data = res.data;
    for (var el in (data as List<dynamic>)) {
      comments.add(Comment(name: el["user"]["name"], comment: el["comment"], createdAt: DateTime.parse(el["created_at"]).toString().substring(0,10)));
    }

    change(comments, status: RxStatus.success());
  }

  addComments(String comment) async {
    final res = await _supabase
        .from('place_comment')
        .insert([
            {'place_id': placeId, "comment": comment,"user_id": _supabase.auth.currentUser?.id}
    ]).execute();

    change(state, status: RxStatus.loading());
    fetchComments();
    return res;
  }

  listenCommentsChange(){
    subscription = _supabase
        .from('place_comment:place_id=eq.$placeId')
        .on(SupabaseEventTypes.insert, handleRecordInsert)
        .subscribe();
  }

  handleRecordInsert(SupabaseRealtimePayload payload) async {
    if(payload.newRecord == null){
      return;
    }

    final res = await Supabase.instance.client
        .from('place_comment')
        .select("""
          *,
          user (
              name
          )
        """)
        .eq('id', payload.newRecord!["id"])
        .execute();

    var cm = Comment(name: (res.data as List<dynamic>)[0]["user"]["name"], comment: (res.data as List<dynamic>)[0]["comment"], createdAt: (res.data as List<dynamic>)[0]["created_at"].toString().substring(0,10));
    state?.insert(0, cm);
    change(state, status: RxStatus.success());

  }

  @override
  void dispose() {
    subscription.unsubscribe();
    super.dispose();
  }
}