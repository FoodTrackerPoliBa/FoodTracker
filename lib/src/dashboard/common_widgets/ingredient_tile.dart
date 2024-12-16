import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/dashboard/create_new_ingredient/create_new_ingredient.dart';
import 'package:food_traker/src/utils.dart';

class IngredientTile extends StatefulWidget {
  final Ingredient ingredient;
  final Widget? trailing;
  const IngredientTile({super.key, required this.ingredient, this.trailing});

  @override
  State<IngredientTile> createState() => _IngredientTileState();
}

class _IngredientTileState extends State<IngredientTile> {
  Ingredient? ingredient;

  @override
  void initState() {
    backend.getFood(id: widget.ingredient.id).then((value) {
      ingredient = value;
      setState(() {});
    });

    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Utils.push(
            context: context,
            routeName: 'create_new_ingredient',
            page: CreateNewIngredient(ingredientId: ingredient?.id));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Builder(builder: (context) {
            if (ingredient == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return AnimatedBuilder(
              animation: backend,
              builder: (context, child) => FutureBuilder<Ingredient>(
                  future: backend.getFood(id: widget.ingredient.id),
                  initialData: ingredient,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error loading ingredient'));
                    }
                    ingredient = snapshot.data;
                    return Row(
                      children: [
                        PreviewThumbIngredient(
                          ingredient: ingredient!,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ingredient!.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        widget.trailing ?? Container(),
                      ],
                    );
                  }),
            );
          }),
        ),
      ),
    );
  }
}

class PreviewThumbIngredient extends StatefulWidget {
  final Ingredient ingredient;
  const PreviewThumbIngredient({super.key, required this.ingredient});

  @override
  State<PreviewThumbIngredient> createState() => _PreviewThumbIngredientState();
}

class _PreviewThumbIngredientState extends State<PreviewThumbIngredient> {
  String? imageUrl;

  @override
  void initState() {
    if (widget.ingredient.imageUrl == null) {
      backend.getFoodImageUrl(widget.ingredient).then((value) {
        imageUrl = value;
        setState(() {});
      });
    } else {
      imageUrl = widget.ingredient.imageUrl;
    }
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl == null
          ? const _DefaultThumb()
          : Image(
              image: CachedNetworkImageProvider(imageUrl!),
              fit: BoxFit.cover,
              height: 50,
              width: 50,
              errorBuilder: (context, error, stackTrace) {
                return const _DefaultThumb();
              },
            ),
    );
  }
}

class _DefaultThumb extends StatelessWidget {
  const _DefaultThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        height: 50,
        width: 50,
        child: const Icon(Icons.fastfood));
  }
}
