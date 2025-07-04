# SubtitleMerger

SwiftUI tabanlı **macOS** uygulaması — Coursera (ve diğer) videoları ile `.vtt` altyazı dosyalarını tek tıklamayla birleştirerek, altyazıyı MP4 dosyasının içine gömer.

## Özellikler

- Sürükle-bırak ya da "Gözat" butonu ile video (.mp4/.mkv) seçimi
- `.vtt` (WEBVTT) altyazı dosyası seçimi
- `ffmpeg` kullanarak yeniden sıkıştırma olmadan hızlı birleştirme (`-c copy`)
- Altyazı dili `tur` olarak etiketlenir; QuickTime ve iOS oynatıcılarında otomatik görünür
- Sonuç dosyasını uygulama içi AVPlayer ile hemen önizleme

## Kurulum

1. macOS 11 Big Sur veya üzeri
2. Xcode 13+ (Swift 5.9/6)
3. Homebrew üzerinden `ffmpeg`:
   ```bash
   brew install ffmpeg
   ```
4. Projeyi klonlayın:
   ```bash
   git clone https://github.com/MehmetKadirDeniz/coursera-subtitle-translator.git
   cd coursera-subtitle-translator
   ```
5. Çalıştırma (Swift Package Manager):
   ```bash
   swift run
   ```
   veya Xcode ile açıp `Run` tuşuna basın.

## Kullanım

1. Uygulama açıldığında "Video Seç" butonuna tıklayıp MP4 dosyanızı seçin.
2. "Altyazı Seç" ile ilgili `.vtt` dosyasını seçin.
3. "Birleştir (ffmpeg)" butonuna tıklayın. Aynı klasörde `*_tr.mp4` dosyası oluşur.
4. Dilerseniz "Oynat" butonu ile sonucu izleyin.

## Lisans

MIT Lisansı — ayrıntılar için `LICENSE` dosyasına bakın. 