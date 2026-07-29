import 'dart:io';
import 'package:flutter/material.dart';

// Tampilkan gambar dari URL atau file lokal
Widget productImage(String imagePath,
    {double width = 80, double height = 80, BoxFit fit = BoxFit.cover}) {
  if (imagePath.isEmpty) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  if (imagePath.startsWith('http')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image, color: Colors.grey),
        ),
      ),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, color: Colors.grey),
      ),
    ),
  );
}
