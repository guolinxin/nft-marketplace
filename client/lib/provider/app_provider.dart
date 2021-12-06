import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/gql_query.dart';
import '../core/services/graphql_service.dart';
import '../core/services/wallet_service.dart';
import '../core/utils/utils.dart';
import '../models/collection.dart';
import '../models/nft.dart';
import '../screens/create_wallet_screen/create_wallet_screen.dart';
import 'wallet_provider.dart';

enum AppState { empty, loading, loaded, success, error, unauthenticated }

class AppProvider with ChangeNotifier {
  final WalletService _walletService;
  final WalletProvider _walletProvider;
  final GraphqlService _graphql;

  AppProvider(
    this._walletService,
    this._walletProvider,
    this._graphql,
  );

  //APP PROVIDER VAR
  AppState state = AppState.empty;
  String errMessage = '';

  //HOME PAGE
  List<Collection> topCollections = [];
  List<NFT> featuredNFT = [];

  //CREATOR PAGE
  List<Collection> userCreatedCollections = [];
  List<NFT> userCollected = [];

  // List<

  //METHODS

  initialize() async {
    final privateKey = _walletService.getPrivateKey();

    if (privateKey.isEmpty) {
      _handleUnauthenticated();
    } else {
      //FIRST - INITIALIZE WALLET
      await _walletProvider.initializeWallet();
      //
      fetchInitialData();

      _handleLoaded();
    }
  }

  fetchInitialData() async {
    // _handleLoading();

    //FETCHING HOME SCREEN DATA
    final data = await _graphql.get(qHome);

    ///Fetch other screen data in background
    _getCreatorPageData();

    //Model Collections
    topCollections = data['collections']
        .map<Collection>((collection) => Collection.fromMap(collection))
        .toList();

    //Model NFTS
    featuredNFT =
        data['nfts'].map<NFT>((collection) => NFT.fromMap(collection)).toList();

    _handleLoaded();
  }

  _getCreatorPageData() async {
    final data =
        await _graphql.get(qCreator, {'uAddress': _walletProvider.address.hex});

    userCreatedCollections = data['collections']
        .map<Collection>((collection) => Collection.fromMap(collection))
        .toList();

    userCollected =
        data['nfts'].map<NFT>((collection) => NFT.fromMap(collection)).toList();
  }

  logOut(BuildContext context) async {
    await _walletService.setPrivateKey('');

    _handleUnauthenticated();

    scheduleMicrotask(() {
      Navigation.popAllAndPush(
        context,
        screen: const CreateWalletScreen(),
      );
    });
  }

  void _handleEmpty() {
    state = AppState.empty;
    errMessage = '';
    notifyListeners();
  }

  void _handleLoading() {
    state = AppState.loading;
    errMessage = '';
    notifyListeners();
  }

  void _handleLoaded() {
    state = AppState.loaded;
    errMessage = '';
    notifyListeners();
  }

  void _handleUnauthenticated() {
    print('as');
    state = AppState.unauthenticated;
    errMessage = '';
    notifyListeners();
  }

  void _handleSuccess() {
    state = AppState.success;
    errMessage = '';
    notifyListeners();
  }

  void _handleError(e) {
    state = AppState.error;
    errMessage = e.toString();
    notifyListeners();
  }
}
