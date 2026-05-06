# Mobile Apps

Prof: Rolando Gonzales

## History and Context

- iPhone: the first touchscreen smartphone
- Android: Google's open source OS based on Linux

- Google thought that they would have to invent a new programming language
and an IDE in order to develop mobile applications. However, this would take
a long time - around 6 years - and they decided it would be too long.

- In order to get around this problem, Google based their new language on JAVA,
a multiplatform language that was already well-known and fit perfectly for developing
a new type of platform.

- Additionally, they decided to use Eclipse IDE, an IDE made for using multiple
languages that came with extended functionalities in the form of plugins.

- Around this time, the first frameworks were developed:
  - PhoneGap, Titanium, Corona SDK, Xamarin, etc...

- As well as native tools for development:
  - Xcode, Eclipse + ADT, Interface Builder, Android SDK Tools

### Maturity of the Ecosystem (2013-2019)

- 2013: iOS 7, flat design
- 2014: Android L, Swift for iOS, material design
- 2015: React native open source, android studio
- 2016: progressive web apps, instant apps
  - mobile web traffic overtook desktop web traffic for the first time in history
- 2017: flutter preview, iPhone X (Face ID)
- 2018: Android Pie (AI), Flutter 1.0 stable

- The emergence of firebase, android studio, dependency injections, etc.

### Modern Era (2020-2025)

- AI, Deep Learning, Machine Learning
  - ML Kit
  - Core ML
  - TensorFlow Lite
  - On-device LLMs
  - Computer vision

- Security and Privacy

- Biometrics

- Performance and Sustainability

- Google developed Dalvik, their own version of the KVM (the older JVM).
This reduced costs, they kept Java, and they kept their OS,
although this introduced legal issues against Google, they ended up winning.

## Android Studio

- SDK selection is important for the version of Android
that you will be developing for.

## Mobile Programming I

- Why android?
  - emerging and huge market
  - dp, sp, px, and pixel density are all android screen space units
  - open source
  - rich ecosystem

### Android Studio Tips

#### Directory

- MyApplication/
  - manifests/
    - androidmanifest.xml
  - java/ -> java code for the app
  - res/ -> visual resources
    - drawable/ -> images and icons (PNG, JPG, WebP, or Shape, Vector, Selector)
    - layout/ -> xml design for the screen
    - mipmap/ -> exclusively used for the app's launcher icon
    - values/ -> strings, colours, themes
      - strings.xml
      - colors.xml
      - themes.xml
    - anim/ -> animations declared in XML
    - menu/ -> app menus (options, navigation, etc.)
  - build.gradle -> config and dependencies

androidmanifest.xml is the app's identity. It declares the name of the app,
the permissions it needs, the activities that it does, what is the primary screen
that will show when booting up the app, and how many interfaces it has.

java/ is where all the java code lives. Each java file represents a class.
The most important class is MainActivity.java which is like a main function.

res/ is where all the visual resources of the app live (layout, etc)

build.gradle is the config file for the project. Here is where all the dependencies
are loaded. Kinda like a package.toml

#### Package Names

- package names turn into the names that show up in the play store

- no two packages can have the same name

- com.example.com (utepsa.edu.myfirstapplication)

#### AVD

- AVD

## Resolutions

- density-independent pixels (dp)
  - the most important unit in android for layouts.
  - 1 dp equals the same physical size on the screen independent of density.
  - use this for padding, margins, button sizes, etc.

- scale-independent pixels
  - like dp, but respects the configuration for the user's system font size
  - if the user decides to increase the size of the font in their system settings,
  the dp scales automatically

- real pixels
  - absolute pixels. The problem is that 100px in a phone of low density occupies
  twice the size of screen space than one with a high density.
  - almost never use these

- points, millimetres, inches (pt, mm, in)
  - real world physical units.
  - these are rarely used because they depend on the quality of the screen's sensor
  and are not reliable on every device.

- small (320x426 dp)

- normal (320x470 dp)

- large (480x640 dp)

- xlarge (720x960 dp)

## What are resources in Android?

- resources are external files to Java code that contain static values for any app:
text, colours, dimensions, images, styles and visuals, etc.

- Android manages these resources with a directory under res/

| Without Res | With Res |
| -------------- | --------------- |
| TextView tv = new TextView(this); | <string name="welcome!">Welcome</string> |
| tv.setText("Welcome"); | This simple change affects the whole app |
| This is difficult to maintain | The code is much much easier to write |

- advantages of using res/:
  - maintenance
  - reusable
  - internationalisation (easy to code multiple languages in the app)
  - screen adaptation

## R Class

Each time that a project is compiled, android studio generates a class called R.
This class contains numerical ID references for each resource defined in XML files.
The programmer never edits R.java directly, and they only make references to it
within their code.

## Screen Density (DPI)

- DPI

## XML

- XML is a similar language to HTML because it uses tags

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
  <string name="app_name">My Application</string>
  <!-- name is the unique identifier for the resource -->
  <string name="hello">Hello, welcome!</string>
</resources>
```

- XML Declaration
- Root Tag
  - <resources></resources>
  - vs.
  - <html></html>
- attribute name
  - the attribute name is the unique identifier for the resource.
  This gives a reference from java's R.string.name or from XML
  @string/name.
  It must be unique within the type of resource.

- Flow (from XML to Java)
  - strings.xml
  - android studio compilation
  - R.java (generated automatically)
  - Java code

How R.Java is shown as an example:

```java
public final class R {
  public static final class string {
    public static final int 
      app_name = 0x7f0b0000;
    public static final int
      hello = 0x7f0b0001;
  }
}
```

How R is used within Java:

```java
// access within Java
String text = getString(
  R.string.app_name
);

// access within XML layout
android:text=
"@string/app_name"
```

### XML Rules

- SNAKE_CASE

## String resources, what are they and why we use them

- impossible to use multiple languages
- inconsistent risks
- limited accessibility
- maintenance is difficult

### string resources, how to access them

1. from an XML file

```xml
<TextView
  android:text=
    "@string/hello"
/>

<Button
  android:text=
    "@string/btn_submit"
/>
```

### colour formats

- RGB
- ARGB
- RRGGBB (most common)
- AARRGGBB (recommended)

- A is for opacity

#### how to access and use colours

1. colors.xml file

```xml
<resources>
  <color name="primary_color">
    #1565C0
  </color>

  <color name="secondary_color">
    #2E7D32
  </color>


  <color name="white_background">
    #FFFFFF 
  </color>

  <color name="grey_background">
    #F5F5F5
  </color>
</resources>
```

### comparing XML vs Java

| strings.xml | colors.xml | key differences |
| --------------- | --------------- | --------------- |
| stores UI texts | stores hex colour values | string -> always plain text |

## best practises and conventions

- general strings
  - initial_title
  - btn_submit
  - hint_password

- error strings
  - error_empty_field
  - error_connection
  - error_format

- primary colours
  - colour_primary
  - colour_secondary

- background colours
  - white_background
  - grey_background

## Themes vs. Styles

- Themes apply to the entire app, and styles are applied to a single component.

- Application (global level)

```xml
android:theme = "@style/Theme.App"
```

- Activity (for a single screen)

```xml
android:theme = "@style/Theme.login"
```

- View (component level)

```xml
style="@style/MyButton"
```

### themes.xml file structure

- colour_primary
  - the app's primary colour
  - appears in the AppBar and featured elements

- colour_secondary
  - accent colour
  - used in FABs, switches, and secondary elements

- colour_background
  - app's background and dialogue background colour

- colour_surface
  - colour for surfaces like cards and bottom sheets

- colour_on_primary
  - text and icon colours
  - usually white

```xml
<?xml version="1.0" encoding="utf-8"
<resources>

  <style name="Theme.ResourcesXML" parent="THeme.MaterialComponentes.DayNight.NoActionBar">
    <!-- Primary Palette -->
    <item name="colour_primary">
      @color/colour_primary
    </item>

    <!-- Secondary Palette -->
    <item name="colour_secondary">
      @color/colour_secondary
    </item>

    <!-- Background and Surfaces -->
    <item name="colour_background">
      @color/colour_background
    </item>

  </style>
</resources>
```

- App level:

```xml
<application
  android:theme=
  "@style/Theme.ResourcesXML">
</application>
```

### Colour Hierarchy

- Theme.MaterialComponents.DayNight (base material design from google)
  - Theme.MaterialComponents.DayNight.NoActionBar (no action bar)
    - Theme.ResourcesXML (your theme, app extends this theme)

```xml
<style name="Button.Primary"
        parent="Widgets.MaterialComponents.Button">
  <item name="android:paddingTop">

  </item>
</style>
```

- styles allow you to group visual objects and reuse them in different views
in the layout.
- these are defined in res/values/themes.xml or in a separate file in
res/values/styles.xml

- TextAppearance is a special style that only affects text

### Themes and Styles Best Practises

- application themes:
  Theme.ResourcesXML | Theme.ResourcesXML.Login

- button styles:
  - Button.Primary | Button.Secondary | Button.Warning

- text styles:
  - Text.Title | Text.Subtitle | Text.Tag

## Drawables

- Icons and Text
- SVG
- Layer list and selectors
- states (pressed, on hover, on click, etc.)

### what are drawables

- a drawable is any graphical element that are distributed on a screen
- in android, these are saved in /res/drawable and reference the code with
@drawable/name or in java with R.drawable.name

- types of drawables:
  - bitmap
    - raster image PNG or JPG
    - an array of pixels arranged in a way to create an image
    - logo.png

  - shape
    - geometrical shape defined in xml.
    - ideal for button backgrounds, fields, and cards
    - background_button.xml

  - vector
    - vector graphics SVG adapted for Android
    - scales to any size without losing quality
    - menu.xml

  - layer list
    - this stacks various drawables in layers
    - card_background.xml

  - selector
    - changes the drawable according to the state of the view:
    normal, pressed, inactive
    - btn_selector.xml

### shape drawable

A shape drawable defines geometric shapes in XML. They don't require an
image and are rendered directly in the view.

```xml
<shape android:shape="rectangle">
  <solid></solid>
  <stroke></stroke>
  <corners></corners>
  <padding></padding>
  <gradient></gradient>
</shape>
```

#### gradients

A gradient element within a shape allows you to create gradients.
Substitutes the solid element.

```xml
<shape android:shape="rectangle">
  <solid></solid>
  <stroke></stroke>
  <corners></corners>
  <padding></padding>
  <gradient
    android:type="linear"
    android:angle="90"
    android:startColor="@color/primary"
    android:endColor="@color/secondary">
  </gradient>
</shape>
```

#### vectors

A vector is based on mathematical lines drawn across the display.

```xml
<vector
  android:width="24dp"
  android:height="24dp"
  android:viewportWidth="24"
  android:viewportHeight="24">

  <path></path>
</vector>
```

#### how to import svgs

Android studio uses a tool to import svg files and convert them automatically
to an XML drawable vector format. This avoids having to write pathData.

1. right click on /res/drawable/
2. select new > vector asset
3. on asset type, choose local file (svg, psd)
4. look for a .svg file in your disc
5. adjust name, size, and colour if necessary
6. click on next and finish

```xml
android:src="@drawable/icon_shop"
```

```java
imageView.setImageResource(R.drawable.icon_shop);
```

#### layer lists

```xml
<layer-list xmlns:android=...
  <!-- Layer 1 (shadow) -->

```

#### selectors

```xml
<selector xmlns:android=...>
  <!-- State: pressed -->
  <item android:state_pressed="true"
   android:drawable="@drawable/btn_pressed"></item>

  <!-- State: inactive -->
  <item android:state_enabled="false"
   android:drawable="@drawable/btn_inactive"></item>

</selector>
```

### best practises for graphical resources

- vector icons
  - icon_description

- background views
  - bg_description

- state selectors
  - sel_description

- raster images
  - img_description

## Views

A view is the basic block structure of an android display. It occupies a rectangular
area on the screen and is responsible for drawings and interactions with the user.

- Hierarchy
  - Views are organised in trees (viewgroup contains views)

- Inheritance
  - all views inherit the android class View

- XML or Code
  - views can be defined in XMl files or in Java

### Properties

| Property | Common Values | Description |
| --------------- | --------------- | --------------- |
| android:id | @+id/name | unique view identifier |
| android:layout_height/width | match_parent.... | component height |
| android:margin | 8dp, 16dp, ... | exterior space around the view |
| android:padding | 8dp, 16dp, ... | space inside the border and the content |

| Property | Common Values | Description |
| --------------- | --------------- | --------------- |
| android:visibility | visible / invisible / gone | controls if the view is shown or not |
| android:background | color / drawable | background |
| android:alpha | 0.0 to 1.0 | opacity |
| android:enabled | true / false | enables or disables user interaction |
| android:gravity | center / start / end / top ... | aligns content within the view |

### TextView

Shows text on the screen. It is only readable.

- properties:
  - android:text
  - android:textSize
  - android:textColor
  - android:textStyle
  - android:textAlignment
  - android:maxLines (amount of visible lines)

### EditText

Editable text field.

- properties:
  - android:hint
  - android:inputType
    - text / number / textPassword / phone / textEmailAddress
  - android:maxLength
  - android:ems

### Button

Button

- properties:
  - android:text
  - android:enabled
  - android:backgroundTint
  - android:textColor
  - android:onClick

```xml
<Button
  android:id="@+id/btnAccept"
  android:enabled="false"
  android:backgroundTint="#abcdef"
/>
```

## Selection Views

### Checkbox

A checkbox is a verification field with two states (true/false).
Allows multiple selections.

- android:text
- android:checked
  - initial state of the field
- android:textSize
- android:buttonTint

### Switch

A literal on/off switch. Functionally identical to the checkbox but
has a toggle appearance which is more optimal for configurations.

- inherits from compound button

### RadioButton and RadioGroup

Allows you to select only one option within a group. They must be
grouped within a RadioGroup for them to be mutually exclusive.

RadioButton attribute:

- all is normal and it also has the checked attribute

RadioGroup attribute:

- android:orientation="horizontal/vertical"

### Spinner

Drop down menu that allows you to select one element from a list of options.
Requires an adapter to load the data.

1. define the spinner in the xml layout with its id
2. create an array of options in strings.xml or directly in java
3. create an arrayadapter in activity with the array of options
4. assign the adapter to the spinner with setAdapter()

```xml
<!-- Layout XML -->
<Spinner 
  android:id="@+id/spCountry"
   ...>
</Spinner>
```

```java
String[] countries = {
  "Bolivia", "Peru"
};

ArrayAdapter adapter = new ArrayAdapter(this, 
android.R.layout.simple_spinner_item, countries);
spCountry.setAdapter(adapter);
```

## Layouts

A layout is an invisible container that organises and positions UI elements
within an android app's screen.

- organises
- contains
- adapts

### Hierarchy view

- layout (viewgroup)
  - child layout
    - view (button)
    - view (textview)
    - etc...

### Key attributes

- match_parent
  - occupies the entire available space of the parent container

- wrap_content
  - size is adjusted

- layout_weight
  - proportionally distributes space between the child views.
  - ex. weight=1 in 3 childs means that each child occupies 1/3 of the space

### Constraint Layout

Allows you to flexibly position views using constraints or restrictions between
them or with the container's border.

### Other Layouts

- RelativeLayout
  - position views relative to other views or to the parent container.

- FrameLayout
  - Stacks views on top of each other. Normally used to show on single
  child at a time, like in the Fragments pattern

- TableLayout
  - Organises views in rows and columns like a html table.
  each row is a TableRow

### Attached Layouts

A layout may contain other layouts like children, forming a hierarchy.
This allows you to build complex interfaces.

#### Golden Rules

- Avoid more than three levels of inheritance

- Always prefer ConstraintLayout
  - this can replace multiple levels of a LinearLayout with a plain design

- Use Merge
  - the "merge" tag eliminates a redundant hierarchy level
  when adding layouts

- Layout Inspector Tool

### Configuring different resolutions

Android supports a great variety of screen resolutions, so you can create
specific layouts per directory to adapt to any device's interface.

| Directory | Description | Device |
| --------------- | --------------- | --------------- |
| res/layout/ | Default layout | basic phone |
| res/layout-sw600dp/ | Screens with less than 600dp min width | 7" tablets |
| res/layout-sw720dp/ | screens with at least 720dp min width | 10" tablets |

## Storage in Android

### Types of storage

- SharedPreferences
  - key-value pairs for configurations and user preferences

- Internal Storage
  - private app files for the device's filesystem

- SQLite
  - relational database

- External Storage
  - SD card or external usb drives

#### Shared Preferences

- Permanently stores key-value pairs

- Data survives after closing the app

- Ideal for simple user preferences

- Supports strings, ints, floats, booleans, and longs

- No SQL required

```java
ed.commit() // is synchronous and blocks the main thread.
ed.apply()  // is the asynchronous and is the preferred method to save data
```

#### SQLite

```java
public class MyDB extends SQLiteOpenHelper {
  static final String DB_NAME = "my_app.db";
  static final int VERSION = 1;
  static final String TABLE = "users";
  
  public MyDB(Context context) {
    super(context, DB_NAME, null, VERSION);
  }

  @Override
  public void onCreate(SQLiteDatabase db) {
    String sql = "create table " + TABLE + " ("
      + "id integer primary key autoincrement,"
      + "name text not null,"
      + "age integer,"
      + "email text unique)";
    db.execSQL(sql);
  }

  @Override
  public void onUpgrade(SQLiteDatabase db, int oldV, int newV) {
    db.execSQL("drop table if exists " + TABLE);
    onCreate(db);
  }
}
```

## Inventory CRUD App

1. Create a new package (database)
2. Create a new class in that package (DBHelper)
3. Define database constants and tables
4. Define the DB constructor
5. In the OnCreate function, execute the tables.

## Services

- A service is to provide something to someone.

- Applications are components of a system.

- Multithreaded programming

- Communication
  - Get
  - Post

- JSON, XML
  - GSON

## Threads

What is a thread?

- A thread can be a little string from a ball of yarn.
  - This string will keep going and going and going, symbolising
  the continuous nature of a main process.

Android apps usually have a main thread. This thread
draws controllers, gets interactions from the user,
and executes transactions or the logic for components.

If this main thread is overloaded, it will freeze. You can avoid this
problem by working with secondary or child threads.

- The main thread can get data from UI elements, then instantiate a new
child thread and then send it the data from the UI element. The child
thread can then process that data.

### Main Thread

The main thread is the only one that can interact with the UI.

### Children Threads

These threads cannot interact with UI elements.

### Creating Threads

Java Thread Class

```java
Thread thread1 = new Thread(() -> {
  // code that will execute in a new thread
});
thread1.start();
```

Java Runnable Interface (not a class)

- This Runnable interface is not a class, as such it doesn't need to be
instantiated nor it can be. However, the thread implements the interface.
If you use this runnable interface, you have to also instantiate a new
Thread class.

```java
Runnable thread2 = () -> {
  // code executed in the thread
}

Thread thread3 = new Thread(thread2);
thread3.start();
```

### Thread States

1. New (created)
2. Runnable (ready)
3. Running (executing)
4. Blocked/Waiting
5. Terminated (Done executing)

- Created is the instantiation of the thread.
- Ready happens as soon as you call start().
- The thread starts executing after you call start().
- Blocked can happen when it is waiting for user input or when something
crashes it.
- Terminated can happen when the thread finished executing
successfully or unsuccessfully.

### Threads in Android

Main Thread

- thread1.start();
- thread2.start();
- thread3.start();
  ...

Operating System (Dalvik Engine)

| T1 | T2 | T3 | T4 |
| --------------- | --------------- | --------------- | --------------- |
| created | running | created | created |

The order that the threads are executed in are not necessarily the order in which
you create them.

**However,** you may assign priorities to the threads.

### Threads interacting with UI elements

For a thread to interact with a UI element, you must call:

- runOnUiThread() function

```java
runOnUiThread(() -> {
  // here you can read values from UI elements
});
```

### Why should you use threads

It adds a bit more complexity to the app's programming, but
it improves the use of resources of the physical device, and it
also improves debugging since using threads can help you isolate
programming logic so you can detect if a process is heavy or
inadequately programmed.

## Services in Android Studio

> [!IMPORTANT]
> WEATHER API KEY
<https://api.openweathermap.org/data/2.5/weather?q=camiri&appid=ee1d5ff9987c89f1a9b00c4e56d9b701>

Here’s a simple guide to using your OpenWeatherMap API key:

1. Base URL
<https://api.openweathermap.org/data/2.5/>

2. Example: Current Weather by City
GET <https://api.openweathermap.org/data/2.5/weather?q={CITY_NAME}&appid={API_KEY}>
Replace {CITY_NAME} with the city and {API_KEY} with your key.

3. Example: Current Weather by Coordinates
GET <https://api.openweathermap.org/data/2.5/weather?lat={LAT}&lon={LON}&appid={API_KEY}>

4. Units & Language
Metric: &units=metric
Imperial: &units=imperial
Language: &lang=es

5. Example Request
<https://api.openweathermap.org/data/2.5/weather?q=La%20Paz&units=metric&lang=es&appid=YOUR_KEY>

6. Basic Python Example
import requests

url = "<https://api.openweathermap.org/data/2.5/weather>"
params = {"q": "La Paz", "units": "metric", "appid": "YOUR_KEY"}
response = requests.get(url, params=params)
print(response.json())

Use this pattern for other endpoints like forecast or onecall
following the same structure with your API key.

### Interfaces

- Interfaces are a set of methods that do not interact with anything,
they can only get data

### Picasso

- You can use picasso to get images from your server (if you have any) and then
load them into your app

### What is a REST API

A REST API (representational state transfer) is a set of rules that allows the communication
between systems through the HTTP protocol.

**This allows mobile apps to:**

- Obtain data from a remote server
- Send information for processing
- Update or delete resources
- Interact with databases in clouds

The android client sends a request to the REST API server and the server
replies with a JSON response.

**HTTP Protocol in Android:**

Android apps communicate with APIs through HTTP requests.

- Communication is asynchronous (doesn't block the UI)
- Requires internet permission in the manifest

### HTTP Methods

Both GET and POST methods send data.

#### GET - Reading Data

**Purpose:**

Request or read data from a server without modifying that data.

- Parametres for the request go through the URL (?key=value)
- Does not modify the server state
- Can be cached

GET /api/users?id=5

#### POST - Sending Data

**Purpose:**

Send data to the server to create or process a resource.

- The data payload goes in the body
- Can create or modify resources
- Is not exposed in the URl

Ex.
POST /api/users {name:"Ana"}

### Stack Tools

1. Retrofit

- This is a library that converts a HTTP API into a Java Interface class.
- Automatically manages HTTP requests, their serialisation, and response requests
asynchronously.

1. GSON

- Google library that converts Java objects into a JSON format and viceversa.
Allows mapping server response directly to Java classes (called POJOs) automatically.

1. Picasso

- Square Inc. library that simplifies image load and visualisation from remote to
local URLs with automatic caching support and error management.

#### Retrofit

Retrofit is a HTTP client that is built to be secure and efficient for Android
and Java. Retrofit converts a HTTP API into a Java interface which lowers the amount
of REST services that are used by an app.

**How it works:**

- A Java interface is created and the get and post methods are implemented
- Retrofit automatically generates the implementation
- The call to the API is asynchronously executed with ``enqueue()``
- The response is received through ``onResponse()`` or ``onFailure()``

**How to install:**

```java
// in build.groovy.gradle
dependencies {
  // Retrofit
  implementation 'com.squareup.retrofit2:retrofit:2.9.0'
}
```

#### GSON

GSON is a Google library that serialises Java objects into JSON format and
deserialises JSON objects into Java code. This is the most used converter
along with Retrofit in order to process server requests.

**Example:**

```java
// Java POJO class with GSON
public class User {
  @SerializedName("id")
  private int id;

  @SerializedName("name")
  private String name;

  ...

  // Getters and Setters
  public int getID() { return id; }
  public String getName() { return name; }
}
```

If its only to serialise objects, setting the class as public is fine.

#### Picasso: Introduction

Picasso is a library that simplifies image loading from remote or local URLs.
It automatically manages caching - it downloads images in the background and
sets their visibility in ImageViews.

**Primary Functions:**

- Loading images from HTTP/HTTPS URLs
- Automatically caching in discs and memory
- Placeholder image whilst its loading
- Error image if it fails to load
- Reloads the image and transforms images

**Basic uses and dependencies:**

```java
// build.gradle
implementation 'com.squareup/picasso:picasso:2.718'
...
```

### Android Project Configuration

**Permissions in AndroidManifest.xml:**

```java
<uses-permission android:name="android.permission.INTERNET" />
```

**Dependencies in build.gradle:**

```java
dependencies {
  implementation 'com.squareup.retrofit2:retrofit:2.9.0'
  implementation 'com.squareup.retrofit2:converter-gson:2.9.0'
  implementation 'com.squareup.picasso:picasso:2.71828'
  implementation 'com.google.code.gson:gson:2.10.1'
}
```

### Data Models (POJO Class)

A POJO (Plain Old Java Object) is a simple Java class that represents
the JSON data structure that every API serves. Every attribute in a
POJO class corresponds to a single JSON field.

**Server JSON Response:**

```java
{
  "id": 1,
  "name": "Ana Garcia",
  "email": "ana@email.com",
  ...
}
```

**POJO Java Class:**

```java
public class User {
  @SerializedName("id")
  private int id;

  @SerializedName("name")
  private String name;

  @SerializedName("email")
  private String email;

  private int getId() { return id; }
  private int getName() { return name; }
  private int getEmail() { return email; }
}
```

### API Interface with Retrofit

**Primary annotations:**

``@GET("route")``
Data read request

``@POST("route")``
Sending data to the server

``@Query("param")``
Parametre in the URL (?param=value)

``@Body``
Sending an object as body in a POST

``@Path("id)``
Variable in the URL route ``/users/{id}``

**ApiService.java:**

```java
public interface ApiService {
  // Get user list
  @GET("users")
  Call<List<User>> getUsers();

  // Search user by ID
  @GET("users/{id}")
  Call<User> searchUser(
    @Path("id") int id
  );

  // Create new user
  @POST("users")
  Call<User> createUser (
    @Body createUser();
  )
}
```

### Retrofit Client

The singleton pattern is used to create a unique Retrofit instance
throughout the app. This avoids creating multiple unnecessary connections
and improves performance.

**RetrofitClient.java:**

```java
public class RetrofitClient {
  private static final String BASE_URL = "https://api.myserver.com/";
  
  private static Retrofit retrofit = null;
  
  public static Retrofit getClient() {
    if (retrofit == null) {
      retrofit = new Retrofit.Builder().baseUrl(BASE_URL).addConverterFactory(GsonConverterFactory.create()).build();
    }
    return retrofit;
  }
}
```

<https://refactoring.guru/design-patterns/singleton>

### Get Method in practise

**Asynchronous call with enqueue() in Activity.class:**

```java
ApiService apiService = RetrofitClient.getClient().create(ApiService.class);

Call<List<User>> call = apiService.getUsers();

call.enqueue(new Callback<List<User>>) {
  @Override
  public void onResponse(Call<List<User>> call, Response<List<User>> response) {
    if (response.isSuccessful()) {
      ...
    }
  }
}
```

### POST Method in Practise

**Sending data to the server with @Body:**

```java
// create the object with the data to send
User newUser = new User();
newUser.setName("Aeropaja Chipilin");
newUser.setEmail("aeropaja@gmail.com")

// get the service
ApiService apiService = RetrofitClient.getClient().create(ApiService.class);

// execute the post request
Call<User> call = apiService.createUser() ...
```

### Picasso in Practise

**Basic use:**

```java
// Simple load from a URL
Picasso.get().load(url).into(imageView);

// With placeholder and error
Picasso.get().load(user.getPhotoUrl()).placeholder(R.drawable.loading).error(R.drawable.no_image).into(imgPhoto);
```

- The placeholder method shows a temporary image whilst the requested image is loading
- The error method is shown if the URL fails or it doesn't exist

**Interaction with Retrofit:**

```java
// In the onResponse() from the GEt
public void onResponse(
  Call<User> call,
  Response<User> respnose) {
  if successful, execute successful code
}
```

### Complete Integrated Workflow

1. UI (Activity)
2. Retrofit
3. API REST (Server)
4. GSON (Parser)
5. ...

### Best Practises

- HTTP Error management
  - Always verify if ``response.isSuccessful()`` before using ``response.body()``
  - Manage error codes like 404 and 500

- Never block the main thread
  - Always use enqueue() for asynchronous calls

- Separate responsibilities
  - Separate network logic in their own classes (RetrofitClient)
  - The POJO model must not contain business

## Web Servers and Mobile Applications

Connecting a website to a web server is free (ex. XAMPP), however
using it with a mobile app is not allowed.

We need an IP address for the phone to connect to the hosted app.

To host our web app, we need:

- A database management system (MySQL, etc.)
- A website programming language like php
- And a web server like Apache XAMPP

### XAMPP

1. In htdocs create a new directory "test"
2. Create a new .php file "test.php"
3. Write:

```php
<?php
  echo "test";
?>
```

#### Getting car pictures from the db to show in the app and a payment method

1. In htdocs create a new directory "vehicles_api"
2. In vehicles_api, create a new directory "imgs"
3. Find five car pictures and move them to "imgs"
4. Go into localhost/phpmyadmin
5. Create the database "db_vehicles"
6. Create a table "Vehicles"
7. Add values:

- IDVehicle int auto_increment primary key,
- LicensePlate varchar(20) not null,
- CarBrand varchar(50) not null,
- CarModel varchar(50) not null,
- Price decimal(10,2) not null,
- State varchar(20) not null default 'Available',
- Picture varchar(500),
- Description TEXT

1. Create a table "Bookings"
2. Add values:

- IDBooking int auto_increment primary key,
- DateBooked datetime not null default current_timestamp,
- DateSold datetime,
- ID_Vehicle int not null,
- ClientName varchar(100) not null,
- ClientPhoneNumber varchar(30) not null,
- State varchar(20) not null default 'Booked',
- foreign key (ID_Vehicle) references Vehicles(IDVehicle)

1. Seed the database with the following values:

```sql
insert into Vehicles(LicensePlate, CarBrand, CarModel, Price, State, Picture,
Description) values (
  "57-NS-12", "Toyota", "Corolla", "2000", "Booked",
  "http://localhost/vehicles_api/imgs/destroyed1.png",
  "Destroyed car automatic and hybrid";
)

insert into Bookings(DateSold, ClientName,
ClientPhoneNumber, State) values (
  "2026-02-25 15:30:11"
)
```

1. Create a new file in vehicles_api "htdocs/vehicles_api/connection.php"
2. Write:

```php
<?php
    ini_set("display_errors", 0);
    error_reporting(0);
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
    header("Access-Control-Allow-Headers: Content-Type");
    $host     = "localhost";
    $user  = "root";
    $password = "";
    $base     = "db_vehicles";
    $connection = new mysqli($host, $user, $password, $base);
    if ($connection->connect_error) {
        http_response_code(500);
        echo json_encode([
            "error" => "Connection error: " . $connection->connect_error
        ]);
        exit();
    }
    $connection->set_charset("utf8");
?>
```

1. Create another file in the same place "get_vehicles.php"
2. Write:

```php
<?php
  require_once('connection.php');

  $sql = "select * from Vehicles order by IDVehicle desc";
  $result = $connection->query($sql);

  $vehicles = []
  if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
      $vehicles[] = $row;
    }
  }

  echo json_encode($vehicles);

  $connection->close();
?>
```

1. Create another file in the same directory "get_vehicle_details.php"

```php
<?php
require_once "connection.php";
if (!isset($_GET["IDVehicle"])) {
    http_response_code(400);
    echo json_encode(["error" => "ID parametre is required."]);
    exit();
}
$id   = intval($_GET["IDVehicle"]);
$sql  = "SELECT * FROM Vehicles WHERE IDVehicle = ?";
$stmt = $connection->prepare($sql);
$stmt->bind_param("i", $id);
$stmt->execute();
$result   = $stmt->get_result();
$vehicle = $result->fetch_assoc();
if ($vehicle) {
    echo json_encode($vehicle);
} else {
    http_response_code(404);
    echo json_encode(["error" => "Vehicle not found."]);
}
$stmt->close();
$connection->close();
?>
```

## 17.04.2026

### Catch-up shit

1. New java class
2. DetailVehicleActivity
3. Create a new activity_detail_vehicle.xml
4. tools:context=".DetailVehicleActivity"
5. Initialise the objects and import them:
6. img picture detail
7. txt brand model
8. txt license plate
9. txt price
10. txt state
11. txt description
12. btn book
13. id vehicle
14. load detail()
15. Import any missing packages
16. In onReserveClick, create a new intent to pass to detailvehicleactivity.class
17. intent.putextra "IDVehicle", vehicle.getId()
18. startActivity(intent)
19. Remember to have xampp boot up, if there is an error, enter config and
change the port from 80 to some other port and then change it back.
20. Create BookingActivity java class
21. give activity_booking.xml a new id "id/main"
22. change tools:context=".BookingActivity"

## What I noticed

### First is the DB connection

- This shit takes too much time and its too complicated.
- There must be some other way to implement this, and in all of this effort to
develop this connection to XAMPP, I completely lost the purpose. This shit is
way too much for something so simple. Something simple enough that I could do
it in a couple of commands in Laravel. There must be some other
method. I will look up Flutter and then I will ask GPT for help with my tech stack.

### Second comes the redundancy

- If there is indeed an easier and less tedious method to implement this DB
connection, I will absolutely never ever use this Android Studio again
for service connections.

## Flutter

```bash
brew install flutter
```

### Widgets tree and display alignment

#### Columns and Rows (alignment properties)

- `mainAxisAlignment`
  - start, center, end, spaceBetween, spaceAround, spaceEvenly

- `crossAxisAlignment`
  - start, center, end, stretch

- `mainAxisSize`
  - max (all available space), min (occupies only what the child elements need)

##### mainAxisAlignment

`start`
All children go to the start of the display (top). Default value.

`center`
All children are grouped around the center axis.

`end`
All children go to the final or bottom part of the display.

`spaceBetween`
Spaces between children objects, no space at the start or end.

`spaceAround`
Spaces around each child. The spaces between the extremes is half.

`spaceEvenly`
Spaces equally between all children objects.

##### ListView.builder

ListView.builder is the RecyclerView equivalent in android studio.
This dynamically creates elements and it only builds the elements that are visible
on the screen at that moment, which is efficient for long lists.

```dart
ListView.builder(
  itemCount: list.length,
  itemBuilder: (ctx, i) {
    return ListTile(
      title: Text(list[i]),
    );
  },
)
```

##### Widgets for every element in a list

In Flutter, the rows in a list are normal widgets. They are directly returned in
the itemBuilder.

**ListTile - Standard row in a list**

```dart
ListTile(
  // Icon on the left
  leading: Icon(
  Icons.directions_car,
  color: Colors.blue,
  ),

  title: Text('Toyota'),
  subtitle: Text('2022'),

  // Icon on the right
  trailing: Icon(
    Icons.chevron_right
  ),
)
```

**Card: Row with shadows and borders**

```dart
Card(
  elevation: 4,
  margin: EdgeInsets.symmetric(
  horizontal: 12, vertical: 6
  ),
 
  shape: RoundedRectangle
  BorderSide(radius: BorderRadius.circular(12)),
  child: ListTile(...),
)
```

Use a ListTile when the list is simple and its
elements don't need visual separation, and use a Card when each
element in a list needs to be seen as visually separate with shadows
and spaces between them.

##### GridView

GridView shows elements in a grid of rows and columns, similar to a RecyclerView.
This has two primary constructors which depend on if the number of columns are
dynamic or if they have to be static on the display.

```dart
GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
  padding: EdgeInsets.all(12),
  children: list.map((v) -> 
  MyCard(v)
  ).toList(),
)
```

You should use a GridView.count when...

##### Navigation

Flutter uses navigation with a stack of pages. Each time there is a new page,
Flutter pushes the page on top of the stack, and if the user goes back, Flutter
does a pop on the stack of pages.

`Navigator.push() == startActivity()`
`Navigator.pop() == finish()`

##### Sending data from one page to another

In Flutter, data is passed to a page through a widget constructor. There are no
Intents or Bundles like in Android. The constructor receives the data and saves
them as attributes to be used in its `build()` method.

Text(vehicle.model) or Text(vehicle.price.toString()) or Image.network(vehicle.img)

```dart
Navigator.push()
```

##### StatefulWidget

This has two classes. The first class is immutable and the second class - which
is the state - is mutable. It saves the data that may change and this uses the `build()`
method to redraw the modified data on the page.

| Class MyWidget (Immutable) | Class _MyWidgetState (Mutable) |
| -------------- | --------------- |
| Only has constructor and createState() | This has build() to redraw data. |

###### StatefulWidget programming flow

1. Import flutter
2. Class 1 only creates State
3. createState() connects the two classes
4. Class 2 is where the data and the build() method live
5. If data can change, this is where you set that option
6. build() is called each time setState() is executed
7. Text shows the current value of the counter with interpolation
from $counter
8. setState() executes the function and automatically redraws the widget.

#### Stateless vs Stateful

Use StatelessWidget when the screen shows static information that is immutable
and will not change.

Use StatefulWidget when there are counters, toggles, sliders, or any element
that visually changes.

## Parsing JSON in Dart

Parsing means to convert JSON into objects that Dart can use.

1. Import dart:convert
2. Decode the JSON file
3. Convert the map into a dart object with `fromJson()`

### Complete model class example

```dart
class Vehicle {
  final int id;
  final String license, brand, model, state, img, description;
  final double price;

  const Vehicle({required this.id, required.this.license....});

  factory Vehicle.fromJson(Map<String, dynamic> map) {
    
  }
}
```

## FutureBuilder: showing asynchronous data in the interface

FutureBuilder is a flutter widget that listens to a future and automatically
rebuilds the interface according to the ...

```dart
define futurebuilder <list<class>>:
  future equals apiservice.method

  builder has (context, snapshot):
    ....
```

## ApiService: separating network logic from the UI

The ApiService class centralises all API calls in a single place.

1. import dart:convert and package:http/http.dart as http
2. import your api class
3. set the base URL as a constant
4. async method that returns a future
5. special header to avoid the ngrok warning page
6. .map() converts each JSON element into your class objects
7. ...

## Installing the http package in your flutter project

1. flutter pub add http
2. specify in pubspec.yaml (dependencies: flutter: sdk: flutter  http: ^1.2.0)
3. import the file that will use it: `import 'package:http/http.dart' as http;`
4. add internet permissions in android: `<uses-permission android:name="android.permission.INTERNET"/>`

## Forms in Flutter: Form and TextFormField

Forms are built with the Form widget and TextFormField fields.
The Form widget acts like a container that groups all fields and allows
you to validate and save their values with what's called a GlobalKey.

## Submit buttons

The most common pattern is to have a single widget that shows the normal button
when its not loaded

## State life cycle

The texteditingcontroller uses memory. If its not freed when the page is closed,
the app will have a memory leak.
