import 'package:flutter/material.dart';

enum AvailableBarcodeTypes {
  url(Icons.link_rounded), //*
  text(Icons.text_fields_rounded),
  phone(Icons.phone),
  email(Icons.email_outlined),
  sms(Icons.sms_outlined);

  final IconData icon;

  const AvailableBarcodeTypes(this.icon);
}
