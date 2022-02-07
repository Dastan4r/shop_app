import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class UserProductEditScreen extends StatefulWidget {
  static const routeName = '/edit-products';

  const UserProductEditScreen({Key? key}) : super(key: key);

  @override
  _UserProductEditScreenState createState() => _UserProductEditScreenState();
}

class _UserProductEditScreenState extends State<UserProductEditScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();

  final _form = GlobalKey<FormState>();

  var editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');

  var initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();

    super.dispose();
  }

  var isInit = true;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;

      if (productId != null) {
        editedProduct = Provider.of<Products>(context, listen: false)
            .findById(productId.toString());

        initValues = {
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price.toString(),
          'imageUrl': '',
        };

        _imageUrlController.text = editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    } else {
      _form.currentState?.save();
    }

    setState(() {
      isLoading = true;
    });

    if (editedProduct.id.isEmpty) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                  title: const Text('An error occurs!'),
                  content: const Text('Something went frong'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Okay'),
                    ),
                  ]);
            });
      } finally {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      }
    } else {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(editedProduct.id, editedProduct);

      Navigator.of(context).pop();
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(isLoading);
    return Scaffold(
      appBar: AppBar(title: const Text('Editing product'), actions: [
        IconButton(
          onPressed: () {
            _saveForm();
          },
          icon: const Icon(Icons.save),
        ),
      ]),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      initialValue: initValues['title'],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          title: value.toString(),
                          id: editedProduct.id,
                          isFavorite: editedProduct.isFavorite,
                          price: editedProduct.price,
                          description: editedProduct.description,
                          imageUrl: editedProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                      initialValue: initValues['price'],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid price';
                        }
                        if (double.parse(value) <= 1) {
                          return 'Please enter a price greater that 0';
                        }
                      },
                      focusNode: _priceFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          title: editedProduct.title,
                          id: editedProduct.id,
                          isFavorite: editedProduct.isFavorite,
                          price: double.parse(value!),
                          description: editedProduct.description,
                          imageUrl: editedProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      initialValue: initValues['description'],
                      maxLines: 3,
                      focusNode: _descriptionFocusNode,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.next,
                      onSaved: (value) {
                        editedProduct = Product(
                          title: editedProduct.title,
                          id: editedProduct.id,
                          isFavorite: editedProduct.isFavorite,
                          price: editedProduct.price,
                          description: value.toString(),
                          imageUrl: editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide a value';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              editedProduct = Product(
                                title: editedProduct.title,
                                id: editedProduct.id,
                                isFavorite: editedProduct.isFavorite,
                                price: editedProduct.price,
                                description: editedProduct.description,
                                imageUrl: value.toString(),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
