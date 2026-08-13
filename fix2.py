with open('d:/flutter/projects/shop/lib/core/widgets/home_app_bar.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("count > 99 ? \\'99+\\' : \\'\\\\',", "count > 99 ? '99+' : '$count',")
text = text.replace("\\'", "'")

with open('d:/flutter/projects/shop/lib/core/widgets/home_app_bar.dart', 'w', encoding='utf-8') as f:
    f.write(text)
