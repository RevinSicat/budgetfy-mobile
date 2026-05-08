import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/local_database_provider.dart';
import 'sync_service.dart';

/// SyncState — tracks sync status for UI feedback
enum SyncStatus { idle, syncing, success, error }

class SyncState {
    final SyncStatus status;
    final DateTime? lastSyncedAt;
    final String? errorMessage;

    const SyncState({
        this.status = SyncStatus.idle,
        this.lastSyncedAt,
        this.errorMessage,
    });

    SyncState copyWith({
        SyncStatus? status,
        DateTime? lastSyncedAt,
        String? errorMessage,
    }) => SyncState(
        status: status ?? this.status,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        errorMessage: errorMessage,
    );
}

/// SyncNotifier — exposes syncAll() and pushPending() to the UI
class SyncNotifier extends Notifier<SyncState> {
    @override
    SyncState build() => const SyncState();

    SyncService get _service => SyncService(ref.read(localDatabaseProvider));

    /// Full sync — pull from Supabase then push pending local changes
    Future<void> syncAll() async {
        if (state.status == SyncStatus.syncing) return;
        state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);
        try {
            await _service.syncAll();
            state = state.copyWith(
                status: SyncStatus.success,
                lastSyncedAt: DateTime.now(),
            );
        } catch (e) {
            state = state.copyWith(
                status: SyncStatus.error,
                errorMessage: e.toString(),
            );
        }
    }

    /// Push only — used after a write when online, no pull needed
    Future<void> pushPending() async {
        if (state.status == SyncStatus.syncing) return;
        try {
            await _service.pushPending();
        } catch (e) {
            print('[SyncNotifier.pushPending]: $e');
            // silent fail — data stays pending and will retry on next syncAll
        }
    }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
    SyncNotifier.new,
);