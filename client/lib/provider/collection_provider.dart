import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfts/config/functions.dart';
import 'package:nfts/core/services/contract_service.dart';
import 'package:nfts/core/services/gasprice_service.dart';
import 'package:nfts/provider/creator_provider.dart';
import 'package:nfts/provider/wallet_provider.dart';
import 'package:web3dart/web3dart.dart';

import '../config/gql_query.dart';
import '../core/services/graphql_service.dart';
import '../core/services/ipfs_service.dart';
import '../models/collection.dart';
import '../models/collection_metadata.dart';
import '../models/nft.dart';

enum CollectionState { empty, loading, loaded, success, error }

class CollectionProvider with ChangeNotifier {
  final IPFSService _ipfs;
  final GraphqlService _graphql;
  final GasPriceService _gasPriceService;
  final ContractService _contractService;
  final CreatorProvider _creatorProvider;

  final WalletProvider _walletProvider;

  CollectionProvider(
    this._ipfs,
    this._graphql,
    this._gasPriceService,
    this._contractService,
    this._creatorProvider,
    this._walletProvider,
  );

  CollectionState state = CollectionState.empty;
  String errMessage = '';

  //Variables
  List<NFT> collectionItems = [];
  CollectionMetaData metaData = CollectionMetaData.initEmpty();
  // Transaction
  CollectionMetaData collectionToCreate = CollectionMetaData.initEmpty();

  String? imageCID;
  String? metadataCID;

  //TO QUE REQUESTS
  List<int> uploadImageQue = [];
  List<int> uploadMetadataQue = [];

  //Upload image to ipfs and store cid
  uploadImage(String imgPath) async {
    try {
      //Add the request to que
      uploadImageQue.add(1);

      imageCID = null;

      imageCID = await _ipfs.uploadImage(imgPath);

      //Remove request from que
      uploadImageQue.removeLast();
    } catch (e) {
      debugPrint('Error at CollectionProvider -> uploadImage: $e');

      //Remove request from que
      uploadImageQue.removeLast();

      _handleError(e);
    }
  }

  //Upload metadata to ipfs and store cid
  uploadMetadata(CollectionMetaData metaDataWithoutImage,
      {bool isRecursive = false}) async {
    try {
      //Add request to que
      if (!isRecursive) {
        uploadMetadataQue.add(1);
      }

      metadataCID = null;

      if (uploadImageQue.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 650));

        uploadMetadata(metaDataWithoutImage, isRecursive: true);
        return;
      }

      collectionToCreate = metaDataWithoutImage.copyWith(image: imageCID);

      metadataCID = await _ipfs.uploadMetaData(collectionToCreate.toMap());

      //remove request from que
      uploadMetadataQue.removeLast();

      _handleSuccess();
    } catch (e) {
      debugPrint('Error at CollectionProvider -> uploadMetadata: $e');

      //remove request from que
      uploadMetadataQue.removeLast();

      _handleError(e);
    }
  }

  createCollection() async {
    try {
      if (uploadMetadataQue.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 650));

        createCollection();
        return;
      }

      final contract = _contractService.marketPlace;

      final transaction = Transaction.callContract(
        contract: contract,
        function: contract.function(fcreateCollection),
        parameters: [
          collectionToCreate.name,
          collectionToCreate.symbol,
          // THIS WILL BE IMAGE
          collectionToCreate.image,
          //THIS WILL BE METADATA
          metadataCID,
        ],
      );

      await _walletProvider.sendTransaction(transaction);
    } catch (e) {
      debugPrint('Error at CollectionProvider -> getTransactionFee: $e');

      _handleError(e);
    }
  }

  getTransactionFee(CollectionMetaData collection) {
    final contract = _contractService.marketPlace;

    final transaction = Transaction.callContract(
      from: _walletProvider.address,
      contract: contract,
      function: contract.function(fcreateCollection),
      parameters: [
        collection.name,
        collection.symbol,
        // THIS WILL BE IMAGE
        'bafybeielrpyysfeos56qr2paenj5zmdamvry3rkyyzld4zua7xnpgeg3py',
        //THIS WILL BE METADATA
        'bafkreiggxphdigslrtq3d3qkgo65ohmggprsvcbqixxcodhpdzgn2ppxba',
      ],
    );

    _walletProvider.getTransactionFee(transaction);
  }

  // confi

  //TODO :Check colletion on opean sea 0x5ee04c97881eb4da8892b209c8baad55c3c17b30

  fetchCollectionMeta(Collection collection) async {
    try {
      state = CollectionState.loading;
      //reset State
      metaData = CollectionMetaData.initEmpty();
      collectionItems.clear();

      final gData = await _graphql.get(qCollection, {
        'cAddress': collection.cAddress,
        'creator': collection.creator,
      });

      //Collection Items
      collectionItems =
          gData['nfts'].map<NFT>((nft) => NFT.fromMap(nft)).toList();

      _handleLoaded();

      final stopWatch = Stopwatch();
      stopWatch.start();

      final data = await _ipfs.getJson(collection.metadata);

      metaData = CollectionMetaData.fromMap(data);

      print(stopWatch.elapsed);

      notifyListeners();
    } catch (e) {
      debugPrint('Error at CollectionProvider -> fetchCollectionMeta: $e');

      _handleError(e);
    }
  }

  void _handleEmpty() {
    state = CollectionState.empty;
    errMessage = '';
    notifyListeners();
  }

  void _handleLoading() {
    state = CollectionState.loading;
    errMessage = '';
    notifyListeners();
  }

  void _handleLoaded() {
    state = CollectionState.loaded;
    errMessage = '';
    notifyListeners();
  }

  void _handleSuccess() {
    state = CollectionState.success;
    errMessage = '';
    notifyListeners();
  }

  void _handleError(e) {
    state = CollectionState.error;
    errMessage = e.toString();
    notifyListeners();
  }
}
