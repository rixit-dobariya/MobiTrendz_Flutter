import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobitrendz/controllers/category_controller.dart';
import 'package:mobitrendz/controllers/filter_controller.dart';

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  final FilterController filterController = Get.find<FilterController>();
  final CategoryController categoryController = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Filters",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        return categoryController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xffF2F3F2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Categories",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...categoryController.categories.map((cat) {
                              return Obx(() => CheckboxListTile(
                                    value: filterController.selectedCategories
                                        .contains(cat.id),
                                    onChanged: (_) =>
                                        filterController.toggleCategory(cat.id),
                                    title: Text(
                                      cat.name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ));
                            }).toList(),
                            const SizedBox(height: 20),
                            const Text(
                              "Price Range",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Obx(() {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "₹${filterController.minPrice.value.toInt()} - ₹${filterController.maxPrice.value.toInt()}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  RangeSlider(
                                    values: RangeValues(
                                      filterController.minPrice.value,
                                      filterController.maxPrice.value,
                                    ),
                                    min: 0,
                                    max: 300000,
                                    divisions: 1000,
                                    onChanged: (RangeValues values) {
                                      filterController.updatePriceRange(
                                        values.start,
                                        values.end,
                                      );
                                    },
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          filterController
                              .applyFilters(filterController.allProducts);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Apply",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        filterController.clearFilters();
                      },
                      child: const Text(
                        "Clear Filters",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
      }),
    );
  }
}
