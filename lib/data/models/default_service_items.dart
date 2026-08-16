/// The maintenance schedule a new vehicle is seeded with.
///
/// These are sensible commuter-motorcycle defaults for the 100–160cc bikes
/// common in Bangladesh and similar markets — deliberately conservative,
/// because a rider who services early loses money and a rider who services
/// late loses an engine. Every one of them is editable or deletable; nothing
/// here is treated as authoritative.
class DefaultServiceItem {
  const DefaultServiceItem({
    required this.name,
    required this.iconKey,
    this.intervalKm,
    this.intervalDays,
  });

  final String name;
  final String iconKey;

  /// Declared in kilometres for readability; converted to the canonical
  /// metres at seed time.
  final int? intervalKm;
  final int? intervalDays;
}

const kDefaultServiceItems = <DefaultServiceItem>[
  DefaultServiceItem(name: 'Engine oil', iconKey: 'oil', intervalKm: 2000),
  DefaultServiceItem(name: 'Oil filter', iconKey: 'filter', intervalKm: 4000),
  DefaultServiceItem(
    name: 'Air filter clean',
    iconKey: 'air',
    intervalKm: 3000,
  ),
  DefaultServiceItem(
    name: 'Air filter replace',
    iconKey: 'air',
    intervalKm: 12000,
  ),
  DefaultServiceItem(name: 'Chain lube', iconKey: 'chain', intervalKm: 500),
  DefaultServiceItem(name: 'Chain adjust', iconKey: 'chain', intervalKm: 1500),
  DefaultServiceItem(
    name: 'Chain + sprocket set',
    iconKey: 'chain',
    intervalKm: 20000,
  ),
  DefaultServiceItem(name: 'Spark plug', iconKey: 'spark', intervalKm: 8000),
  DefaultServiceItem(
    name: 'Brake pads (front)',
    iconKey: 'brake',
    intervalKm: 10000,
  ),
  DefaultServiceItem(
    name: 'Brake pads (rear)',
    iconKey: 'brake',
    intervalKm: 12000,
  ),
  DefaultServiceItem(name: 'Brake fluid', iconKey: 'fluid', intervalDays: 730),
  DefaultServiceItem(name: 'Coolant', iconKey: 'coolant', intervalDays: 730),
  DefaultServiceItem(name: 'Tyre (front)', iconKey: 'tyre', intervalKm: 25000),
  DefaultServiceItem(name: 'Tyre (rear)', iconKey: 'tyre', intervalKm: 15000),
  DefaultServiceItem(name: 'Battery', iconKey: 'battery', intervalDays: 1095),
  DefaultServiceItem(
    name: 'Valve clearance',
    iconKey: 'valve',
    intervalKm: 12000,
  ),
  DefaultServiceItem(name: 'Full service', iconKey: 'wrench', intervalKm: 5000),
];
