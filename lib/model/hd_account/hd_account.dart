class HdAccount {
  HdAccount({
    required this.accountIndex,
    required this.addresses,
    this.derivationPath,
    this.totalBalance,
  });

  factory HdAccount.fromJson(Map<String, dynamic> json) {
    return HdAccount(
      accountIndex: json['account_index'],
      derivationPath: json['derivation_path'],
      totalBalance: HdBalance.fromJson(json['total_balance']),
      addresses: json['addresses']
          .map<HdAddress>((dynamic item) => HdAddress.fromJson(item))
          .toList(),
    );
  }

  final int accountIndex;
  final String? derivationPath;
  final HdBalance? totalBalance;
  final List<HdAddress> addresses;
}

class HdAddress {
  HdAddress({
    required this.address,
    required this.derivationPath,
    required this.chain,
    required this.balance,
  });

  factory HdAddress.fromJson(Map<String, dynamic> json) {
    return HdAddress(
      address: json['address'],
      derivationPath: json['derivation_path'],
      chain: json['chain'],
      balance: HdBalance.fromJson(json['balance']),
    );
  }

  final String address;
  final String derivationPath;
  final String chain;
  final HdBalance balance;
}

class HdBalance {
  HdBalance({
    required this.spendable,
    required this.unspendable,
  });

  factory HdBalance.fromJson(Map<String, dynamic> json) {
    return HdBalance(
      spendable: double.parse(json['spendable'] ?? '0'),
      unspendable: double.parse(json['unspendable'] ?? '0'),
    );
  }

  double spendable;
  double unspendable;
}
