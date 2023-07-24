# CStickerView

**自定义贴纸容器，支持平移、旋转、缩放、单指旋转等功能（支持图片贴纸和文字贴纸）**

# 使用方法
```
let imageView1 = UIImageView(image: UIImage(named: "testImage1"))
imageView1.contentMode = .scaleAspectFit
let sticker1 = CStickerView(frame: CGRect(x: 100, y: 100, width: imageView1.frame.width, height: imageView1.frame.height), view: imageView1)
self.view.addSubview(sticker1)

let label1 = UILabel()
label1.text = "Hello, World!!!"
label1.font = UIFont.systemFont(ofSize: 20)
label1.textAlignment = .center
let sticker2 = CStickerView(frame: CGRect(x: 100, y: 600, width: 160, height: 60), view: label1)
self.view.addSubview(sticker2)
```
