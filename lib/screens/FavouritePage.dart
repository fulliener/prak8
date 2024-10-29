import 'package:flutter/material.dart';
import 'package:prak8/screens/ItemPage.dart';
import 'package:prak8/api_service.dart';
import 'package:prak8/model/items.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key, required this.navToShopCart});

  final Function(int i) navToShopCart;

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<Items>> ItemsFavList;
  late List<Items> UpdatedItemsFavList;

  @override
  void initState() {
    super.initState();
    ItemsFavList = ApiService().getFavoriteProducts();
    ApiService().getFavoriteProducts().then(
          (value) => {UpdatedItemsFavList = value},
    );
  }

  void _refreshData() {
    setState(() {
      ItemsFavList = ApiService().getFavoriteProducts();
      ApiService().getFavoriteProducts().then(
            (value) => {UpdatedItemsFavList = value},
      );
    });
  }

  void AddFavorite(Items this_item) {
    Items new_item = Items(
      id: this_item.id,
      name: this_item.name,
      image: this_item.image,
      cost: this_item.cost,
      describtion: this_item.describtion,
      favorite: !this_item.favorite,
      shopcart: this_item.shopcart,
      count: this_item.count,
    );
    ApiService().updateProductStatus(new_item);
    setState(() {
      _refreshData();
    });
  }

  void NavToItem(index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemPage(
          index: index,
          navToShopCart: (i) => widget.navToShopCart(i),
        ),
      ),
    );
    _refreshData();
  }

  void AddShopCart(Items this_item) async {
    Items new_item = Items(
      id: this_item.id,
      name: this_item.name,
      image: this_item.image,
      cost: this_item.cost,
      describtion: this_item.describtion,
      favorite: this_item.favorite,
      shopcart: !this_item.shopcart,
      count: 1,
    );
    ApiService().updateProductStatus(new_item);
    setState(() {
      UpdatedItemsFavList.elementAt(
        UpdatedItemsFavList.indexWhere((el) => el.id == this_item.id),
      ).shopcart = !this_item.shopcart;
      UpdatedItemsFavList.elementAt(
        UpdatedItemsFavList.indexWhere((el) => el.id == this_item.id),
      ).count = 1;
    });
  }

  void increment(Items this_item) {
    Items new_item = Items(
      id: this_item.id,
      name: this_item.name,
      image: this_item.image,
      cost: this_item.cost,
      describtion: this_item.describtion,
      favorite: this_item.favorite,
      shopcart: this_item.shopcart,
      count: this_item.count + 1,
    );
    ApiService().updateProductStatus(new_item);
    setState(() {
      UpdatedItemsFavList.elementAt(
        UpdatedItemsFavList.indexWhere((el) => el.id == this_item.id),
      ).count += 1;
    });
  }

  void decrement(Items this_item) {
    final count = this_item.count;
    Items new_item;
    if (count == 1) {
      new_item = Items(
        id: this_item.id,
        name: this_item.name,
        image: this_item.image,
        cost: this_item.cost,
        describtion: this_item.describtion,
        favorite: this_item.favorite,
        shopcart: false,
        count: 0,
      );
    } else {
      new_item = Items(
        id: this_item.id,
        name: this_item.name,
        image: this_item.image,
        cost: this_item.cost,
        describtion: this_item.describtion,
        favorite: this_item.favorite,
        shopcart: this_item.shopcart,
        count: this_item.count - 1,
      );
    }
    ApiService().updateProductStatus(new_item);
    setState(() {
      if (count == 1) {
        UpdatedItemsFavList.elementAt(
          UpdatedItemsFavList.indexWhere((el) => el.id == this_item.id),
        ).shopcart = false;
      } else {
        UpdatedItemsFavList.elementAt(
          UpdatedItemsFavList.indexWhere((el) => el.id == this_item.id),
        ).count -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Избранное'),
        backgroundColor: Colors.grey[200],
      ),
      body: FutureBuilder<List<Items>>(
        future: ItemsFavList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет избранных товаров'));
          }

          final ItemsFavList = snapshot.data!;
          return SingleChildScrollView( // Добавление прокрутки
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Отключение прокрутки GridView
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.63,
              ),
              itemCount: ItemsFavList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    NavToItem(ItemsFavList.elementAt(index).id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: Image.network(
                              ItemsFavList.elementAt(index).image,
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: MediaQuery.of(context).size.width * 0.4,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator();
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  height: MediaQuery.of(context).size.width * 0.4,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Text(
                                      'нет картинки',
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                '${ItemsFavList.elementAt(index).name}',
                                style: const TextStyle(fontSize: 12),
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              children: [
                                const Text(
                                  'Цена: ',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${ItemsFavList.elementAt(index).cost} ₽',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      onPressed: () => {
                                        AddFavorite(
                                          UpdatedItemsFavList.elementAt(index),
                                        ),
                                      },
                                      icon: const Icon(Icons.favorite),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          UpdatedItemsFavList.elementAt(index).shopcart
                              ? SizedBox(
                            height: 40.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => {
                                    decrement(
                                      UpdatedItemsFavList.elementAt(index),
                                    ),
                                  },
                                ),
                                Container(
                                  height: 25.0,
                                  width: 30.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.grey[300],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${UpdatedItemsFavList.elementAt(index).count}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => {
                                    increment(
                                      UpdatedItemsFavList.elementAt(index),
                                    ),
                                  },
                                ),
                              ],
                            ),
                          )
                              : ElevatedButton(
                            onPressed: () => {
                              AddShopCart(UpdatedItemsFavList.elementAt(index)),
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey[700],
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 2.0,
                              ),
                            ),
                            child: const Text(
                              'В корзину',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
