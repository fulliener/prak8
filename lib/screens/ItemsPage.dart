import 'package:flutter/material.dart';
import 'package:prak8/screens/AddPage.dart';
import 'package:prak8/screens/ItemPage.dart';
import 'package:prak8/api_service.dart';
import 'package:prak8/model/items.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key, required this.navToShopCart});

  final Function(int i) navToShopCart;

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late Future<List<Items>> ItemsList;
  late List<Items> UpdatedItemsList;

  @override
  void initState() {
    super.initState();
    ItemsList = ApiService().getProducts();
    ApiService().getProducts().then((value) => {UpdatedItemsList = value});
  }

  void _refreshData() {
    setState(() {
      ItemsList = ApiService().getProducts();
      ApiService().getProducts().then((value) => {UpdatedItemsList = value});
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
      UpdatedItemsList.elementAt(
          UpdatedItemsList.indexWhere((el) => el.id == this_item.id))
          .favorite = !this_item.favorite;
    });
  }

  void AddShopCart(Items this_item) async {
    Items new_item = Items(
      id: this_item.id,
      name: this_item.name,
      image: this_item.image,
      cost: this_item.cost,
      describtion: this_item.describtion,
      favorite: this_item.favorite,
      shopcart: true,
      count: 1,
    );
    ApiService().updateProductStatus(new_item);
    setState(() {
      UpdatedItemsList.elementAt(
          UpdatedItemsList.indexWhere((el) => el.id == this_item.id))
          .shopcart = true;
      UpdatedItemsList.elementAt(
          UpdatedItemsList.indexWhere((el) => el.id == this_item.id))
          .count = 1;
    });
  }

  void NavToAdd(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPage()),
    );
    _refreshData();
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
      UpdatedItemsList.elementAt(
          UpdatedItemsList.indexWhere((el) => el.id == this_item.id))
          .count += 1;
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
        UpdatedItemsList.elementAt(
            UpdatedItemsList.indexWhere((el) => el.id == this_item.id))
            .shopcart = false;
      } else {
        UpdatedItemsList.elementAt(
            UpdatedItemsList.indexWhere((el) => el.id == this_item.id))
            .count -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Товары'),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Icon(
                Icons.add,
                size: 30,
              ),
            ),
            onPressed: () {
              NavToAdd(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Items>>(
        future: ItemsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final ItemsList = snapshot.data!;
          return ItemsList.isNotEmpty
              ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.63,
            ),
            itemCount: ItemsList.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  NavToItem(ItemsList.elementAt(index).id);
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(7.0),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Image.network(
                            ItemsList.elementAt(index).image,
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
                                color: Colors.grey[200],
                                child: const Center(
                                    child: Text(
                                      'нет картинки',
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                    )),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: SizedBox(
                            height: 35.0,
                            child: Text(
                              '${ItemsList.elementAt(index).name}',
                              style: const TextStyle(fontSize: 12),
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 5.0),
                          child: Row(
                            children: [
                              const Text(
                                'Цена: ',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${ItemsList.elementAt(index).cost} ₽',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 6, 196, 9),
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () => {
                                      AddFavorite(UpdatedItemsList.elementAt(index))
                                    },
                                    icon: UpdatedItemsList.elementAt(index).favorite
                                        ? const Icon(Icons.favorite, color: Colors.red)
                                        : const Icon(Icons.favorite_border),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Количество товаров в корзине
                        UpdatedItemsList.elementAt(index).shopcart
                            ? SizedBox(
                          height: 40.0,
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    decrement(UpdatedItemsList.elementAt(index));
                                  },
                                ),
                                Text(
                                  '${UpdatedItemsList.elementAt(index).count}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    increment(UpdatedItemsList.elementAt(index));
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                            : IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            AddShopCart(UpdatedItemsList.elementAt(index));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
              : const Center(child: Text('Нет товаров.'));
        },
      ),
    );
  }
}
