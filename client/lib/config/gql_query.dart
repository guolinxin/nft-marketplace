//FOR GQLQUERY START WITH qTHENQUERYNAME

// Home page

const qHome = r'''
    query homeQuery($first: Int) {
      collections(orderBy: volumeOfEth, orderDirection: desc, first: 3) {
        cAddress
        name
        image
        creator
      }
      nfts(first: $first) {
        cAddress
        tokenId
        name
        image
        collectionName
        creator
      }
    }
''';

// Collection page

const qCollection = r'''
    query collectionQuery($cAddress: String, $creator: String) {
      users(where: {uAddress: $creator}) {
        name
      }
      collections(where: {cAddress: $cAddress}) {
        name
        image
        metadata
        nItems
        volumeOfEth
      }
      nfts(where: {cAddress: $cAddress}) {
        tokenId
        name
        image
      }
    }
''';

// NFT page

const qNFT = r'''
    query nftQuery($cAddress: String, $tokenId: Int, $creator: String) {
      users(where: {uAddress: $creator}) {
        name
        image
        metadata
      }
      nfts(where: {cAddress: $cAddress, tokenId: $tokenId}) {
        name
        image
        collectionName
        properties
        metadata
        creator
        owner
      }
      nftevents(where: {cAddress: $cAddress, tokenId: $tokenId}) {
        id
        eventType
        from
        to 
        price
        timestamp
      }
      bids(where: {cAddress: $cAddress, tokenId: $tokenId}) {
        from
        price
      }
    }
''';

// Creator page

const qCreator = r'''
    query creatorQuery($uAddress: String) {
      users(where: {uAddress: $uAddress}) {
        name
        image
        metadata
      }
      collections(where: {creator: $uAddress}) {
        cAddress
        name
        image
        nItems
      }
      nfts(where: {owner: $uAddress}) {
        cAddress
        tokenId
        name
        image
        collectionName
        creator
      }
    }
''';
