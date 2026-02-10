import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firestore_lookup_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/order_entities.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_details_sheet.dart';
import '../widgets/order_filters.dart';
import '../widgets/order_stats_cards.dart';

/// Orders management page.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  final _tabs = [
    const _OrderTab(null, 'الكل', Iconsax.document),
    const _OrderTab(OrderStatus.pending, 'قيد الانتظار', Iconsax.timer_1),
    const _OrderTab(OrderStatus.preparing, 'قيد التجهيز', Iconsax.clock),
    const _OrderTab(OrderStatus.ready, 'جاهز', Iconsax.tick_circle),
    const _OrderTab(OrderStatus.onTheWay, 'في الطريق', Iconsax.truck_fast),
    const _OrderTab(OrderStatus.delivered, 'تم التسليم', Iconsax.tick_square),
    const _OrderTab(OrderStatus.cancelled, 'ملغي', Iconsax.close_circle),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Note: Initial LoadOrders is dispatched in app_router.dart BlocProvider.create

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final selectedTab = _tabs[_tabController.index];
    context.read<OrdersBloc>().add(FilterOrdersByStatus(selectedTab.status));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OrdersBloc>().add(const LoadMoreOrders());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  _buildOrdersList(), // No Expanded here
                ],
              ),
            ),
          ),

          // Order details panel
          BlocBuilder<OrdersBloc, OrdersState>(
            buildWhen: (prev, curr) {
              if (prev is OrdersLoaded && curr is OrdersLoaded) {
                return prev.selectedOrder != curr.selectedOrder;
              }
              return false;
            },
            builder: (context, state) {
              if (state is OrdersLoaded && state.selectedOrder != null) {
                return Container(
                  width: 400,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
                  ),
                  child: OrderDetailsPanel(order: state.selectedOrder!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and stats
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة الطلبات',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'متابعة وإدارة جميع الطلبات',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Refresh button
              IconButton(
                onPressed: () {
                  context
                      .read<OrdersBloc>()
                      .add(const LoadOrders(refresh: true));
                },
                icon: const Icon(Iconsax.refresh),
                tooltip: 'تحديث',
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMd),

          // Stats cards
          const OrderStatsCards(),

          const SizedBox(height: AppConstants.spacingMd),

          // Search and filters
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'بحث برقم الطلب، اسم العميل، المتجر...',
                      prefixIcon: const Icon(Iconsax.search_normal),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                        vertical: AppConstants.spacingSm,
                      ),
                    ),
                    onChanged: (value) {
                      context.read<OrdersBloc>().add(SearchOrders(value));
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              GlassCard(
                padding: const EdgeInsets.all(AppConstants.spacingSm),
                child: IconButton(
                  onPressed: () => _showFiltersSheet(context),
                  icon: const Icon(Iconsax.filter),
                  tooltip: 'فلتر',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
      padding: const EdgeInsets.all(AppConstants.spacingXs),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: _tabs.map((tab) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.icon, size: 18),
                const SizedBox(width: 8),
                Text(tab.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrdersList() {
    return BlocBuilder<OrdersBloc, OrdersState>(
      buildWhen: (prev, curr) {
        if (prev is OrdersLoaded && curr is OrdersLoaded) {
          return prev.filteredOrders != curr.filteredOrders ||
              prev.searchQuery != curr.searchQuery;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        return switch (state) {
          OrdersInitial() => const Center(child: CircularProgressIndicator()),
          OrdersLoading() => _buildLoadingState(),
          OrdersError(:final message, :final previousOrders) =>
            previousOrders != null
                ? _buildOrdersGrid(previousOrders)
                : _buildErrorState(message),
          OrdersLoaded(:final filteredOrders) => filteredOrders.isEmpty
              ? _buildEmptyState()
              : _buildOrdersGrid(filteredOrders),
        };
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return GlassCard(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
          child: const SizedBox(height: 120),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document,
            size: 80,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'لا توجد طلبات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'ستظهر الطلبات الجديدة هنا',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildErrorState(String message) {
    return ErrorState(
      message: message,
      onRetry: () =>
          context.read<OrdersBloc>().add(const LoadOrders(refresh: true)),
    );
  }

  Widget _buildOrdersGrid(List<OrderEntity> orders) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    final crossAxisCount = isDesktop ? 2 : (isTablet ? 2 : 1);

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppConstants.spacingMd,
        crossAxisSpacing: AppConstants.spacingMd,
        mainAxisExtent: 205,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: () => _onOrderTap(order),
          onStatusChange: (status) => _onOrderStatusChange(order.id, status),
        );
      },
    );
  }

  void _onOrderTap(OrderEntity order) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (isDesktop) {
      context.read<OrdersBloc>().add(SelectOrder(order.id));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => OrderDetailsSheet(order: order),
      );
    }
  }

  void _onOrderStatusChange(String orderId, OrderStatus newStatus) {
    context.read<OrdersBloc>().add(UpdateOrderStatusEvent(
          orderId: orderId,
          newStatus: newStatus,
        ));
  }

  void _showFiltersSheet(BuildContext context) {
    final ordersBloc = context.read<OrdersBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ordersBloc,
        child: const OrderFiltersSheet(),
      ),
    );
  }
}

class _OrderTab {
  final OrderStatus? status;
  final String label;
  final IconData icon;

  const _OrderTab(this.status, this.label, this.icon);
}

/// Order details panel for desktop view.
class OrderDetailsPanel extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsPanel({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفاصيل الطلب',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        '#${order.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<OrdersBloc>().add(const ClearSelectedOrder());
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  _buildStatusBadge(context),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Customer info
                  _buildInfoSection(
                    context,
                    'العميل',
                    Iconsax.user,
                    [
                      order.customerName,
                      order.customerPhone,
                      order.address.fullAddress,
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Store info with detailed data
                  if (order.storeId != null) _buildStoreSection(context),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Driver info
                  if (order.driverName != null)
                    _buildInfoSection(
                      context,
                      'السائق',
                      Iconsax.truck,
                      [order.driverName!],
                    ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Items
                  Text(
                    'المنتجات',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  ...order.items.map((item) => _buildItemRow(context, item)),

                  const SizedBox(height: AppConstants.spacingMd),

                  // Total
                  _buildTotalSection(context),

                  const SizedBox(height: AppConstants.spacingMd),

                  // Timeline
                  Text(
                    'مسار الطلب',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  ...order.timeline.map((t) => _buildTimelineItem(context, t)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final color = _getStatusColor(order.status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            order.status.arabicName,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSection(BuildContext context) {
    if (order.storeId == null || order.storeId!.isEmpty) {
      return _buildInfoSection(
        context,
        'المتجر',
        Iconsax.shop,
        [order.storeName ?? 'متجر غير معروف'],
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: sl<FirestoreLookupService>().getUserById(order.storeId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.shop,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'المتجر',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _buildInfoSection(
            context,
            'المتجر',
            Iconsax.shop,
            [order.storeName ?? 'متجر غير معروف'],
          );
        }

        final userData = snapshot.data!;
        // ignore: unnecessary_null_comparison
        if (userData == null) {
          return _buildInfoSection(
            context,
            'المتجر',
            Iconsax.shop,
            [order.storeName ?? 'متجر غير معروف'],
          );
        }

        // Store data is now nested inside the user document
        final storeData =
            (userData['store'] as Map<String, dynamic>?) ?? <String, dynamic>{};

        // Extract store information from nested store map
        final storeName =
            storeData['name'] as String? ?? order.storeName ?? 'متجر غير معروف';
        final storePhone = storeData['phone'] as String? ?? 'غير متوفر';

        // Address is now a simple string in the store map
        String storeAddress = storeData['address'] as String? ?? 'غير متوفر';
        if (storeAddress.isEmpty) {
          storeAddress = 'غير متوفر';
        }

        final storeCategory = storeData['category'] as String? ?? 'متجر';
        final storeRating = (storeData['rating'] as num?)?.toDouble() ?? 0.0;

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.shop,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Row(
                          children: [
                            Text(
                              storeCategory,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                            ),
                            if (storeRating > 0) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.star,
                                  size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                storeRating.toStringAsFixed(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildStoreInfoRow(context, Iconsax.call, storePhone),
              const SizedBox(height: 8),
              _buildStoreInfoRow(context, Iconsax.location, storeAddress),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData icon,
    List<String> lines,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingXs),
        ...lines.map((line) => Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Text(
                line,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            )),
      ],
    );
  }

  Widget _buildItemRow(BuildContext context, OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
      child: Row(
        children: [
          Text(
            '${item.quantity}x',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (item.storeName != null && item.storeName!.isNotEmpty)
                  Text(
                    item.storeName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                  ),
              ],
            ),
          ),
          Text(
            Formatters.currency(item.total),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(BuildContext context) {
    // Calculate actual subtotal from items
    final calculatedSubtotal = order.items.fold<double>(
      0.0,
      (sum, item) => sum + item.total,
    );

    // Use calculated subtotal if order subtotal is missing or incorrect
    final displaySubtotal = (order.subtotal == null ||
            order.subtotal == 0.0 ||
            (calculatedSubtotal > 0 &&
                (calculatedSubtotal - (order.subtotal ?? 0.0)).abs() > 0.01))
        ? calculatedSubtotal
        : order.subtotal!;

    return FutureBuilder<double>(
      future: sl<FirestoreLookupService>().getDriverCommissionRate(),
      builder: (context, snapshot) {
        // Get delivery fee from settings/driverCommission/rate
        double deliveryFee = snapshot.data ?? 0.0;

        final calculatedTotal = displaySubtotal + deliveryFee;
        // Always use calculated total to ensure delivery fee is included
        final displayTotal = calculatedTotal;

        return GlassCard(
          child: Column(
            children: [
              _buildTotalRow(
                context,
                'المجموع الفرعي',
                displaySubtotal,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'رسوم التوصيل',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    Formatters.currency(deliveryFee),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const Divider(),
              _buildTotalRow(
                context,
                'الإجمالي',
                displayTotal,
                isBold: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double amount, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : null,
              ),
        ),
        Text(
          Formatters.currency(amount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : null,
                color: isBold ? AppColors.primary : null,
              ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, OrderTimeline timeline) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _getStatusColor(timeline.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeline.status.arabicName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  Formatters.timeAgo(timeline.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => AppColors.warning,
      OrderStatus.confirmed => AppColors.info,
      OrderStatus.preparing => AppColors.secondary,
      OrderStatus.ready => AppColors.success,
      OrderStatus.pickedUp => AppColors.primary,
      OrderStatus.onTheWay => AppColors.primary,
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
    };
  }
}
