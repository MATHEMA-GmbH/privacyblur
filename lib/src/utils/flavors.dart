enum Flavor { foss, full }

class BuildFlavor {
  static Flavor flavor = Flavor.full;

  static bool get isFoss => flavor == Flavor.foss;
}
