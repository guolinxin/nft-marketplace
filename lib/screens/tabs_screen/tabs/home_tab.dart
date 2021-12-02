import 'package:flutter/material.dart';

import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../collection_screen/collection_screen.dart';
import '../../nft_screen/nft_screen.dart';
import '../widgets/home_app_bar.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: space2x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: rh(70)),
            //APPBAR
            const HomeAppBar(),
            SizedBox(height: rh(space4x)),

            //TOP COLLECTIONS
            UpperCaseText(
              'Top Collections',
              style: Theme.of(context).textTheme.headline4,
            ),

            SizedBox(height: rh(space3x)),

            ListView.separated(
              itemCount: 3,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: rh(space2x));
              },
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => Navigation.push(
                    context,
                    screen: const CollectionScreen(),
                  ),
                  child: CollectionListTile(
                    image: 'assets/images/collection-${index + 1}.png',
                    title: 'Less is More',
                    subtitle: 'By The Minimalist',
                  ),
                );
              },
            ),

            SizedBox(height: rh(space3x)),
            const Divider(),
            SizedBox(height: rh(space3x)),

            //FEATURED NFTS
            UpperCaseText(
              'Featured NFTS',
              style: Theme.of(context).textTheme.headline4,
            ),

            SizedBox(height: rh(space3x)),

            ListView.separated(
              itemCount: 3,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: rh(space3x));
              },
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () =>
                      Navigation.push(context, screen: const NFTScreen()),
                  child: NFTCard(
                    heroTag: '$index',
                    image: 'assets/images/nft-${index + 1}.png',
                    title: 'Woven Into Fabric',
                    subtitle: 'Fabric Cloths',
                  ),
                );
              },
            ),

            SizedBox(height: rh(space3x)),
          ],
        ),
      ),
    );
  }
}
