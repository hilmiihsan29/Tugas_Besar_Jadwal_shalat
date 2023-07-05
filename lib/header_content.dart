import 'package:flutter/material.dart';
import 'package:jadwal_solat/model/jadwal.dart';
import 'package:jadwal_solat/text_style.dart';

class HeaderContent extends StatelessWidget {
  JadwalShalat jadwal;

  HeaderContent(this.jadwal);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20.0,
      bottom: 20.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            jadwal.daerah!,
            style: styleCityHeader,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20.0,
              ),
              Text(
                jadwal.lokasi!,
                style: styleAddressHeader,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              )
            ],
          )
        ],
      ),
    );
  }
}
