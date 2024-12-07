import processing.sound.*;
import controlP5.*;
import java.awt.Desktop;
import java.net.URI;
//News API
import java.util.ArrayList;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.BufferedReader;
import java.io.InputStreamReader;

//News API

SoundFile[] soundfiles;
ControlP5 cp5;

PImage musicWidget;
PImage backgroundImg;
PImage PlannerImg;
PImage WidgetWords;
PImage WidgetStretchingTurtle;
PImage WidgetMusicGreen;
PImage WidgetMusicBlue;
PImage WidgetMusicRed;
PImage WidgetMusicBlack;
PImage WidgetInterview;
PImage WidgetNews;
PImage WidgetFortuneBlue;
PImage MusicImages[];
int currentImageIndex = 0;
PImage WidgetStretchingImages[];
int currentStretchingImageIndex = 0;
PImage WidgetMusicFastforwardbutton;
PImage WidgetMusicRewindbutton;

float alpha = 0;
boolean transitioning = false;

// mouse scroll
boolean isLocked = false;
float pos, npos;

// sound
Boolean isPlay = false;

// text
PFont ef;
PFont kf, kfb;

CColor ccolor;

int currentInterviewImageIndex = 0;
PImage[] interviewImages;

//News API
ArrayList<String> newsTitles = new ArrayList<>();
ArrayList<String> newsLinks = new ArrayList<>();
String apiKey = "07c14b3b08204513a3956d91742d71c0"; // 여에 실제 NHK API 키를 입력했습니다
String nhkUrl = "https://newsapi.org/v2/everything?q=Japan&sortBy=publishedAt&apiKey="+apiKey;
//News API

PFont font;

void setup() {
  size(380, 800);
  background(255);

  MusicImages = new PImage[4];
  MusicImages[0] = loadImage("WidgetMusicGreen.png");
  MusicImages[1] = loadImage("WidgetMusicBlue.png");
  MusicImages[2] = loadImage("WidgetMusicRed.png");
  MusicImages[3] = loadImage("WidgetMusicBlack.png");

  soundfiles = new SoundFile[4];
  soundfiles[0] = new SoundFile(this, "Time Out.mp3");
  soundfiles[1] = new SoundFile(this, "소리꾼.mp3");
  soundfiles[2] = new SoundFile(this, "Back Door.mp3");
  soundfiles[3] = new SoundFile(this, "Chk Chk Boom.mp3");

  WidgetStretchingImages = new PImage[2];
  WidgetStretchingImages[0] = loadImage("WidgetStretchingHuman.png");
  WidgetStretchingImages[1] = loadImage("WidgetStretchingTurtle.png");
  currentStretchingImageIndex = int(random(WidgetStretchingImages.length));

  cp5 = new ControlP5(this);

  cp5.addButton("playBtn")
    .setPosition(270, 850)
    .setImage(loadImage("WidgetMusicPlaybutton.png"))
    .updateSize();
  backgroundImg = loadImage("Widgetbackground.png");
  PlannerImg = loadImage("Planner.png");
  WidgetWords = loadImage("WidgetWords.png");
  WidgetMusicGreen = loadImage("WidgetMusicGreen.png");
  WidgetMusicBlue = loadImage("WidgetMusicBlue.png");
  WidgetMusicRed = loadImage("WidgetMusicRed.png");
  WidgetMusicBlack = loadImage("WidgetMusicBlack.png");
  WidgetInterview = loadImage("WidgetInterview.png");
  WidgetNews = loadImage("WidgetNews.png");
  WidgetFortuneBlue = loadImage("WidgetFortuneBlue.png");
  WidgetMusicFastforwardbutton = loadImage("WidgetMusicFastforwardbutton.png");
  WidgetMusicRewindbutton = loadImage("WidgetMusicRewindbutton.png");
  // text
  ef = createFont("Arial", 16, true);
  kf = createFont("NotoSansKR-Regular.ttf", 48, true);
  kfb = createFont("NanumMyeongjo-Bold.ttf", 16, true);


  ControlFont controlFont = new ControlFont(kfb, 16);

  cp5.setFont(controlFont);

  ccolor = new CColor();
  ccolor.setBackground(color(0, 100, 50))
    .setForeground(color(100, 0, 50))
    .setActive(color(127, 64, 32));
  
  cp5.setColor(ccolor);

  // Initialize interview images
  interviewImages = new PImage[4]; // Assuming you have 3 images
  interviewImages[0] = loadImage("WidgetInterview.png");
  interviewImages[1] = loadImage("WidgetInterview2.png");
  interviewImages[2] = loadImage("WidgetInterview3.png");
  interviewImages[3] = loadImage("WidgetInterview4.png");

  cp5.addButton("WidgetInterviewNextBtn")
    .setPosition(330, 950)
    .setSize(80, 30)
    .setLabel("WidgetInterviewNextBtn")
    .setImage(loadImage("WidgetInterviewRightbutton.png"))
    .onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        startTransition();
      }
    });

  // Fetch News
  fetchNHKNews();
  // Fetch News
  // 일본어 text
  // 일본어 text
  font = createFont("NotoSansJP-Regular", 32, true);
  font = createFont("meiryo", 32, true);
  font = createFont("Yu Gothic Light", 32, true);

  textFont(font);
}

void draw() {
  background(255);
  image(backgroundImg, 0, 0);

  npos = constrain(npos, -800, 0);
  pos += (npos - pos) * 0.1;

  pushMatrix();
  translate(0, int(pos));

  image(PlannerImg, 20, 20);
  image(WidgetWords, 20, 240);
  image(WidgetStretchingImages[currentStretchingImageIndex], 20, 600);
  image(MusicImages[currentImageIndex], 200, 600);
  image(interviewImages[currentInterviewImageIndex], 20, 915);
  image(WidgetNews, 20, 1005);
  image(WidgetFortuneBlue, 20, 1250);
  image(WidgetMusicFastforwardbutton, 310, 850);
  image(WidgetMusicRewindbutton, 230, 850);
  cp5.getController("playBtn").setPosition(270, 850 + pos);
  cp5.getController("WidgetInterviewNextBtn").setPosition(330, 943 + pos);
  if (transitioning) {
    alpha = lerp(alpha, 255, 0.05); // Gradually increase alpha
    if (alpha > 254) {
      alpha = 255;
      transitioning = false; // End transition
    }
  } else {
    alpha = 255; // Ensure full opacity when not transitioning
  }

  tint(255, alpha); // Apply alpha to the image
  image(interviewImages[currentInterviewImageIndex], 20, 915);
  noTint(); // Reset tint

  // text의 색깔 조정
  fill(0);
  // text font, size
  textFont(kf, 14);
  text("플래너", 70, 53);
  text("> 오늘의 일정 1", 50, 110);
  text("> 오늘의 일정 2", 50, 135);
  text("> 오늘의 일정 3", 50, 160);
  fill(255, 0, 0); // 텍스트 색깔을 빨간으로 설정
  text("> D-365 수능", 205, 110);
  text("> D-20 에리카 최종 결과", 205, 135);
  fill(255, 255, 0); // 노란색으로 텍스트 설정
  text("> D-100 3월 모의고사", 205, 160);
  fill(0, 255, 0); // 초록색으로 텍스트 설정
  text("> D-200 6월 모의고사", 205, 185);
  fill(0);
  // processing에는 가운데 정렬 기능이 존재하지 않아 하드코딩 진행
  displayNHKNewsTitles(45, 1080);  // 뉴스 제목들을 표시할 위치 지정
  popMatrix();
}

void startTransition() {
  transitioning = true;
  alpha = 0; // Start with transparent image
  currentInterviewImageIndex = (currentInterviewImageIndex + 1) % interviewImages.length;
}

// Mouse Scroll
void mousePressed() {
  isLocked = true;

  if (mouseX >= 310 && mouseX <= 310 + WidgetMusicFastforwardbutton.width &&
      mouseY >= 850 + pos && mouseY <= 850 + pos + WidgetMusicFastforwardbutton.height) {
    currentImageIndex = (currentImageIndex + 1) % MusicImages.length;
    playCurrentSong();
  }

  if (mouseX >= 230 && mouseX <= 230 + WidgetMusicRewindbutton.width &&
      mouseY >= 850 + pos && mouseY <= 850 + pos + WidgetMusicRewindbutton.height) {
    currentImageIndex = (currentImageIndex - 1) % MusicImages.length;
    if (currentImageIndex == -1) {
      currentImageIndex = MusicImages.length - 1;
    }
    playCurrentSong();
  }

  for (int i = 0; i < newsTitles.size(); i++) {
    if (mouseX >= 45 && mouseX <= 385 && 
        mouseY >= (1080 + i * 20 + pos) && 
        mouseY <= (1095 + i * 20 + pos)) {
      openLink(newsLinks.get(i));
    }
  }
}

void mouseWheel(MouseEvent event) {
  println("mouse wheel");
  float e = event.getCount();
  npos += e * -50;
}

void mouseReleased() {
  isLocked = false;
}

// Sound Play
public void playBtn() {
  println("click btn");

  for (SoundFile sf : soundfiles) {
    if (sf.isPlaying()) {
      sf.stop();
    }
  }

  if (isPlay) {
    soundfiles[currentImageIndex].pause();
    cp5.getController("playBtn").setImage(loadImage("WidgetMusicPlaybutton.png"));
  } else {
    soundfiles[currentImageIndex].play();
    cp5.getController("playBtn").setImage(loadImage("WidgetMusicPausebutton.png"));
  }

  isPlay = !isPlay;
}

void playCurrentSong() {
  for (SoundFile sf : soundfiles) {
    if (sf.isPlaying()) {
      sf.stop();
    }
  }
  soundfiles[currentImageIndex].play();
  cp5.getController("playBtn").setImage(loadImage("WidgetMusicPausebutton.png"));
  isPlay = true;
}


void openLink(String url) {
  try {
    Desktop.getDesktop().browse(new URI(url));
  } catch (Exception e) {
    e.printStackTrace();
  }
}

// Display NHK News Titles
void displayNHKNewsTitles(float x, float y) {
  if (newsTitles.size() == 0) return;

  fill(0);
  textFont(font, 14);
  textAlign(LEFT);
  
 // 한 번에 3개의 기사만 표시
  int maxArticlesToShow = min(3, newsTitles.size());
  for (int i = 0; i < maxArticlesToShow; i++) {
    float yPos = y + (i * 25); // y 좌표를 조정하여 위치 변경
    
    if (mouseX >= x && mouseX <= x + 340 && 
        mouseY >= yPos + pos && mouseY <= yPos + 20 + pos) {
      fill(100);
    } else {
      fill(0);
    }
    
    text(newsTitles.get(i), x, yPos);
  }
}
// Display NHK News Titles

// Fetch NHK News via API
void fetchNHKNews() {
  try {
    // 뉴스 API URL 
    String apiKey = "07c14b3b08204513a3956d91742d71c0"; // 뉴스 API 키
    String nhkUrl = "https://newsapi.org/v2/everything?q=Japan&sortBy=publishedAt&apiKey=" + apiKey;

    URL url = new URL(nhkUrl);
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("GET");

    BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    String inputLine;
    StringBuffer content = new StringBuffer();
    while ((inputLine = in.readLine()) != null) {
      content.append(inputLine);
    }
    in.close();
    conn.disconnect();

    // API 응답 출력
    println("API Response: " + content.toString());  // API 응답 확인

    JSONObject data = parseJSONObject(content.toString());
    if (data == null) {
      throw new Exception("Failed to parse JSON response");
    }

    newsTitles.clear(); // 리스트 초기화
    newsLinks.clear();  // 리스트 초기화

    // 뉴스 목록 가져오기
    JSONArray articles = data.getJSONArray("articles");
    println("Number of articles: " + articles.size()); // 기사 수 확인

    for (int i = 0; i < articles.size(); i++) {
      JSONObject article = articles.getJSONObject(i);
      String title = article.getString("title");
      String articleUrl = article.getString("url");

      // URL에 .jp가 포함된 경우에만 추가
      if (articleUrl.contains(".jp")) {
        newsTitles.add(title);
        newsLinks.add(articleUrl);
      }
    }

    println("Total news articles added: " + newsTitles.size());

  } catch (Exception e) {
    println("Error fetching NHK News: " + e.getMessage());
    e.printStackTrace();

    newsTitles.clear();
    newsLinks.clear();
  }
}

