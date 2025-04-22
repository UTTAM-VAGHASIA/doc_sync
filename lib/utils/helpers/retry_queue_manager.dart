import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doc_sync/utils/helpers/models/retry_job_model.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:get/get.dart';

class RetryQueueManager extends GetxController {
  static RetryQueueManager get instance => Get.find<RetryQueueManager>();

  final List<RetryJob> _queue = [];

  @override
  void onInit() {
    super.onInit();

    // Listen to network changes and auto-retry
    ever<List<ConnectivityResult>>(
      NetworkManager.instance.connectionStatus,
      (statusList) {
        if (!statusList.contains(ConnectivityResult.none)) {
          _processQueue();
        }
      },
    );
  }

  /// Add a failed request to the queue
  void addJob(RetryJob job) {
    _queue.add(job);
    print("Job added to queue. Total: ${_queue.length}");
  }

  /// Try all jobs in the queue
  Future<void> _processQueue() async {
    print("🔁 Retrying ${_queue.length} job(s)...");
    while (_queue.isNotEmpty) {
      final job = _queue.removeAt(0);
      try {
        await job();
        print("✅ Job retried successfully");
      } catch (e) {
        print("❌ Job retry failed. Re-adding to queue...");
        _queue.add(job); // optional: add back to queue or log it
        break; // stop processing if one fails again
      }
    }
  }
}
