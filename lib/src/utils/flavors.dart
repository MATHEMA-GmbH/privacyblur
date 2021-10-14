enum Flavor { FOSS, FULL }

class BuildFlavor {
  static Flavor flavor = Flavor.FULL;

  static bool get isFoss => flavor == Flavor.FOSS;
}
