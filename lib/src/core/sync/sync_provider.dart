import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/local_database_provider.dart';
import 'sync_service.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncState {
    final SyncStatus status;
    final DateTime? lastSyncedAt;
    final String? errorMessage;

    const SyncState({
        this.status = SyncStatus.idle,
        this.lastSyncedAt,
        this.errorMessage
    });

    SyncState copyWith({ SyncStatus? status,
            DateTime? lastSyncedAt,
            String? errorMessage }) => SyncState(
        status: status ?? this.status,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        errorMessage: errorMessage
    );
}

class SyncNotifier extends Notifier<SyncState> {
    @override
    SyncState build() => const SyncState();

    SyncService get service => SyncService(ref.read(localDatabaseProvider));

    Future<void> syncAll() async {
        if (state.status == SyncStatus.syncing) {
            return;
        }
        state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);
        try {
            await service.syncAll();
            state = state.copyWith(
                status: SyncStatus.success,
                lastSyncedAt: DateTime.now()
            );
        } catch (e) {
            state = state.copyWith(
                status: SyncStatus.error,
                errorMessage: e.toString()
            );
        }
    }

    Future<void> pushRecordNow() async {
        if (state.status == SyncStatus.syncing) {
            return;
        }
        try {
            await service.pushRecordNow();
        } catch (e) {
            print('[SyncNotifier.pushRecordNow]: $e');
        }
    }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
    SyncNotifier.new
);