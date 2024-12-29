import 'package:flutter/material.dart';

class OverviewCard extends StatelessWidget {
 final String title;
 final VoidCallback? onTap; 
 final IconData? icon; 

 const OverviewCard({
   super.key,
   required this.title,
   this.onTap,
   this.icon, // เพิ่มไอคอน
 });

 @override
 Widget build(BuildContext context) {
   return GestureDetector( 
     onTap: onTap,
     child: Container(
       width: double.infinity,
       padding: const EdgeInsets.all(30),
       decoration: BoxDecoration(
         color: Colors.green,
         borderRadius: BorderRadius.circular(12),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.1),
             blurRadius: 4,
             offset: const Offset(0, 2),
           ),
         ],
       ),
       child: Center(
         child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             if (icon != null) Icon(icon, color: Colors.white), // แสดงไอคอนถ้ามี
             if (icon != null) const SizedBox(width: 8), // เพิ่มช่องว่างระหว่างไอคอนกับข้อความ
             Text(
               title,
               style: const TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w500,
                 color: Colors.white, // เปลี่ยนสีตัวอักษรเป็นสีขาวเพื่อให้เห็นชัดบนพื้นสีเขียว
               ),
               maxLines: 2,
               textAlign: TextAlign.center, // จัดให้ข้อความอยู่กึ่งกลาง
               overflow: TextOverflow.ellipsis,
             ),
           ],
         ),
       ),
     ),
   );
 }
}