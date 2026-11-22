import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../../core/constants/owner_destination.dart';
import '../../models/owner_dashboard_data.dart';
import '../../repositories/owner_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/listing_tile.dart';
import '../../widgets/logout_dialog.dart';
import '../../widgets/message_tile.dart';
import '../../widgets/owner_drawer.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/subscription_card.dart';
import 'owner_placeholder_screen.dart';
import 'add_hostel_listing_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key, this.repository});

  /// Optional, for tests. Defaults to the app-wide [ownerRepository].
  final OwnerRepository? repository;

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  static const double _maxContentWidth = 600;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  OwnerDashboardData? _data;
  bool _loading = true;
  bool _failed = false;

  OwnerRepository get _repo => widget.repository ?? ownerRepository;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_data == null) {
      setState(() {
        _loading = true;
        _failed = false;
      });
    }
    try {
      final data = await _repo.getDashboard();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      if (_data == null) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not refresh. Try again.')),
        );
      }
    }
  }

  // ---------- Navigation (placeholders for now) ----------

  Widget _screenFor(OwnerDestination d) {
    switch (d) {
      case OwnerDestination.dashboard:
        return const OwnerPlaceholderScreen(title: 'Dashboard'); // unused
      case OwnerDestination.myListings:
        // TODO(my-listings chat): replace with MyListingsScreen.
        return OwnerPlaceholderScreen(title: d.title);
      case OwnerDestination.messages:
        // TODO(messages chat): replace with OwnerMessagesScreen.
        return OwnerPlaceholderScreen(title: d.title);
      case OwnerDestination.subscription:
        // TODO(subscription chat): replace with SubscriptionScreen.
        return OwnerPlaceholderScreen(title: d.title);
      case OwnerDestination.profile:
        // TODO(profile chat): replace with OwnerProfileScreen.
        return OwnerPlaceholderScreen(title: d.title);
      case OwnerDestination.help:
        // TODO(help chat): replace with HelpSupportScreen.
        return OwnerPlaceholderScreen(title: d.title);
    }
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _open(OwnerDestination d) {
    if (d == OwnerDestination.dashboard) return; // already here
    _push(_screenFor(d));
  }

  void _openAddListing() {
    // TODO(add-listing chat): replace with AddListingScreen.
    _push(const AddHostelListingScreen());
}

  void _openNotifications() {
    // TODO(notifications): replace with NotificationsScreen.
    _push(const OwnerPlaceholderScreen(title: 'Notifications'));
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showLogoutDialog(context);
    if (!confirmed || !mounted) return;
    try {
      // AuthGate listens to the auth stream and shows RoleSelectionScreen
      // as soon as the user is signed out. No manual navigation needed.
      await AuthService.instance.signOut();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log out. Please try again.')),
      );
    }
  }

  // ---------- UI ----------

  Widget _centered(Widget child) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxContentWidth),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      key: _scaffoldKey,
      drawer: data == null
          ? null
          : OwnerDrawer(
              profile: data.profile,
              subscription: data.subscription,
              selected: OwnerDestination.dashboard,
              onSelect: _open,
              onLogout: _confirmLogout,
            ),
      body: SafeArea(
        child: Column(
          children: [
            _centered(_buildTopBar(data)),
            Expanded(child: _centered(_buildBody(data))),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(OwnerDashboardData? data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
            onTap: data == null
                ? null
                : () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data?.profile.hostelName ?? 'CampusNest',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.heading(size: 22),
                ),
                Text(
                  'Owner dashboard',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(size: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            showDot: (data?.profile.unreadMessages ?? 0) > 0,
            onTap: _openNotifications,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(OwnerDashboardData? data) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (data == null || _failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load your dashboard.',
                textAlign: TextAlign.center,
                style: AppText.body(color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          SubscriptionCard(
            info: data.subscription,
            onManage: () => _open(OwnerDestination.subscription),
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatCard(
                    value: '${data.listings.length}',
                    label: 'Listings',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    value: '${data.profile.unreadMessages}',
                    label: 'New messages',
                    valueColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    value: '${data.profile.rating.toStringAsFixed(1)}★',
                    label: 'Rating',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Recent messages',
            actionLabel: 'View all',
            onAction: () => _open(OwnerDestination.messages),
          ),
          if (data.recentMessages.isEmpty)
            _emptyText('No messages yet.')
          else
            for (final m in data.recentMessages)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MessageTile(
                  message: m,
                  onTap: () => _open(OwnerDestination.messages),
                ),
              ),
          const SizedBox(height: 14),
          const SectionHeader(title: 'My listings'),
          if (data.listings.isEmpty)
            _emptyText('No listings yet. Tap "+ Add New Listing" below.')
          else
            for (final l in data.listings)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListingTile(
                  listing: l,
                  onTap: () => _open(OwnerDestination.myListings),
                ),
              ),
        ],
      ),
    );
  }

  Widget _emptyText(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: AppText.body(size: 13, color: AppColors.textMuted),
    ),
  );

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: _centered(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: PrimaryButton(
            label: '+ Add New Listing',
            onPressed: _openAddListing,
          ),
        ),
      ),
    );
  }
}
