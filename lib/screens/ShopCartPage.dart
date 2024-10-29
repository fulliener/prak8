import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:prak8/screens/ItemPage.dart';
import 'package:prak8/api_service.dart';
import 'package:prak8/model/items.dart';

class ShopCartPage extends StatefulWidget {
  const ShopCartPage({super.key, required this.navToShopCart});

  final Function(int i) navToShopCart;

  @override
  State<ShopCartPage> createState() => _ShopCartPageState();
}

class _ShopCartPageState extends State<ShopCartPage> {
  late Future<List<Items>> ItemsFromCart;
  late List<Items> UpdatedItemsFromCart;

  @override
  void initState() {
    super.initState();
    ItemsFromCart = ApiService().getShopCartProducts();
    ApiService().getShopCartProducts().then(
          (value) => {UpdatedItemsFromCart = value},
    );
  }

  void _refreshData() {
    setState(() {
      ItemsFromCart = ApiService().getShopCartProducts();
      ApiService().getShopCartProducts().then(
            (value) => {UpdatedItemsFromCart = value},
      );
    });
  }

  // Удаление из корзины
  Future<bool?> _confirmDismiss() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Удалить товар из корзины?',
                  style: TextStyle(fontSize: 16.00, color: Colors.black),
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Ок',
                  style: TextStyle(color: Colors.black, fontSize: 14.0)),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            TextButton(
              child: const Text('Отмена',
                  style: TextStyle(color: Colors.black, fontSize: 14.0)),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> confirmDismiss() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFE0E0E0),  // Светло-серый фон окна
          title: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Удалить товар из корзины?',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],  // Светло-серая кнопка "Ок"
              ),
              child: const Text('Ок',
                  style: TextStyle(color: Colors.black, fontSize: 14.0)),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],  // Светло-серая кнопка "Отмена"
              ),
              child: const Text('Отмена',
                  style: TextStyle(color: Colors.black, fontSize: 14.0)),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }


  // Переход на страницу с товарами
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
        count: this_item.count + 1);
    ApiService().updateProductStatus(new_item);
    setState(() {
      UpdatedItemsFromCart.elementAt(
          UpdatedItemsFromCart.indexWhere((el) => el.id == this_item.id))
          .count += 1;
    });
  }

  void decrement(Items this_item) {
    final count = this_item.count;
    Items new_item;
    if (count > 1) {
      new_item = Items(
          id: this_item.id,
          name: this_item.name,
          image: this_item.image,
          cost: this_item.cost,
          describtion: this_item.describtion,
          favorite: this_item.favorite,
          shopcart: this_item.shopcart,
          count: this_item.count - 1);
      ApiService().updateProductStatus(new_item);
    }
    setState(() {
      if (count > 1) {
        UpdatedItemsFromCart.elementAt(
            UpdatedItemsFromCart.indexWhere((el) => el.id == this_item.id))
            .count -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Корзина'),
          backgroundColor: Colors.white70,
        ),
        body: FutureBuilder<List<Items>>(
            future: ItemsFromCart,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Корзина пуста'));
              }

              final ItemsFromCart = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: ItemsFromCart.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          return index == ItemsFromCart.length
                              ? SizedBox(
                            height: 30.0,
                            child: Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 5.0),
                                  child: Text(
                                    'Количество товаров в корзине: ${UpdatedItemsFromCart.fold(0, (sum, item) => sum + item.count)}',
                                    style:
                                    const TextStyle(fontSize: 14.0),
                                  ),
                                ),
                              ),
                            ),
                          )
// удаление с помощью свайпа влево
                              : Slidable(
                            key: Key(ItemsFromCart.elementAt(index)
                                .id
                                .toString()),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    bool? answer =
                                    await _confirmDismiss();
                                    if (answer == true) {
                                      Items new_item = Items(
                                          id:
                                          UpdatedItemsFromCart.elementAt(index)
                                              .id,
                                          name:
                                          UpdatedItemsFromCart.elementAt(index)
                                              .name,
                                          image:
                                          UpdatedItemsFromCart.elementAt(index)
                                              .image,
                                          cost:
                                          UpdatedItemsFromCart.elementAt(index)
                                              .cost,
                                          describtion:
                                          UpdatedItemsFromCart.elementAt(index)
                                              .describtion,
                                          favorite:
                                          UpdatedItemsFromCart.elementAt(index)
                                              .favorite,
                                          shopcart: !UpdatedItemsFromCart
                                              .elementAt(index)
                                              .shopcart,
                                          count:
                                          !UpdatedItemsFromCart.elementAt(index)
                                              .shopcart
                                              ? 1
                                              : 0);
                                      ApiService()
                                          .updateProductStatus(new_item);
                                      setState(() {
                                        UpdatedItemsFromCart.removeAt(
                                            UpdatedItemsFromCart
                                                .indexWhere((el) =>
                                            el.id ==
                                                ItemsFromCart
                                                    .elementAt(
                                                    index)
                                                    .id));
                                      });
                                      _refreshData();
                                    }
                                  },
                                  backgroundColor: const Color.fromRGBO(
                                      158, 158, 158, 1.0),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                ),
                              ],
                            ),

// карточка товара
                            child: GestureDetector(
                              onTap: () {
                                NavToItem(
                                    ItemsFromCart.elementAt(index).id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10.0,
                                    left: 10.0,
                                    top: 2.0,
                                    bottom: 5.0),
                                child: Container(
                                  height:
                                  MediaQuery.of(context).size.height *
                                      0.2,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    borderRadius:
                                    BorderRadius.circular(7.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(10.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey,
                                                width: 1),
                                          ),
                                          child: Image.network(
                                            ItemsFromCart.elementAt(index)
                                                .image,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.3,
                                            height: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.3,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context,
                                                child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const CircularProgressIndicator();
                                            },
                                            errorBuilder: (context, error,
                                                stackTrace) {
                                              return Container(
                                                width:
                                                MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    0.3,
                                                height:
                                                MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    0.3,
                                                color: Colors.grey,
                                                child: const Center(
                                                    child: Text(
                                                      'нет картинки',
                                                      softWrap: true,
                                                      textAlign:
                                                      TextAlign.center,
                                                    )),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20.0,
                                            right: 5.0,
                                            left: 10.0,
                                            bottom: 10.0),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 50.0,
                                              width:
                                              MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.55,
                                              child: Text(
                                                '${ItemsFromCart.elementAt(index).name}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                                softWrap: true,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20.0,
                                              width:
                                              MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.55,
                                              child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    const Text(
                                                      'Цена: ',
                                                      style: TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      '${ItemsFromCart.elementAt(index).cost * UpdatedItemsFromCart.elementAt(index).count} ₽',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Color
                                                              .fromARGB(
                                                              255,
                                                              6,
                                                              196,
                                                              9),
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    ),
                                                  ]),
                                            ),
//изменение количества товара
                                            SizedBox(
                                              height: 50.0,
                                              width:
                                              MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.4,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    left: 5.0,
                                                    right: 5.0),
                                                child: Row(children: [
                                                  IconButton(
                                                      icon: const Icon(
                                                          Icons.remove),
                                                      onPressed:
                                                          () => {
                                                        decrement(
                                                            UpdatedItemsFromCart.elementAt(
                                                                index))
                                                      }),
                                                  Container(
                                                    height: 30.0,
                                                    width: 40.0,
                                                    decoration:
                                                    BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          5.0),
                                                      border: Border.all(
                                                          color: const Color
                                                              .fromRGBO(
                                                              0,
                                                              0,
                                                              0,
                                                              1.0),
                                                          width: 2),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .all(5.0),
                                                      child: Text(
                                                        UpdatedItemsFromCart
                                                            .elementAt(
                                                            index)
                                                            .count
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize:
                                                            14.0,
                                                            color: Colors
                                                                .black),
                                                        textAlign:
                                                        TextAlign
                                                            .center,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                      icon:
                                                      const Icon(Icons.add),
                                                      onPressed:
                                                          () => {
                                                        increment(
                                                            UpdatedItemsFromCart.elementAt(
                                                                index))
                                                      }),
                                                ]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      border: Border(
                        top: BorderSide(
                          color: Color.fromRGBO(158, 158, 158, 1.0),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Text('Сумма товаров: '),
                          Text(
                            '${UpdatedItemsFromCart.fold(0.0, (sum, item) => sum + item.count * item.cost)} ₽',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 6, 196, 9),
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                    const Color.fromARGB(255, 0, 0, 0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side: const BorderSide(
                                            width: 2,
                                            color: Color.fromRGBO(
                                                0, 0, 0, 1.0))),
                                    backgroundColor: const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                  child: const Text("Купить",
                                      style: TextStyle(fontSize: 12)),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }));
  }
}