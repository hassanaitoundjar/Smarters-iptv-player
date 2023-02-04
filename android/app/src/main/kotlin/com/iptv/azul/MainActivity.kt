package com.iptv.azul

//import android.os.AsyncTask
//import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//import java.io.BufferedReader
//import java.io.InputStreamReader
//import java.net.HttpURLConnection
//import java.net.URL

class MainActivity : FlutterActivity() {

   /* private val CHANNEL = "com.iptv.azul/data"
    private val PACKAGE = "com.md.azul";
    private val UNIQUEKEY = "hello_worl";
    private lateinit var flutterEngine: FlutterEngine

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.flutterEngine = flutterEngine
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getDataResult") {
                GetDataFromApi().execute("https://mouadzizi.me/envato/app.php?key=$UNIQUEKEY&package=$PACKAGE")
            } else {
                result.notImplemented()
            }
        }
    }

    private inner class GetDataFromApi : AsyncTask<String, Void, String>() {

        override fun doInBackground(vararg params: String?): String {
            val apiUrl = params[0]
            var result = ""
            val url = URL(apiUrl)
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "GET"
            val inputStream = conn.inputStream
            val bufferedReader = BufferedReader(InputStreamReader(inputStream))
            val response = StringBuilder()
            var line = bufferedReader.readLine()
            while (line != null) {
                response.append(line)
                line = bufferedReader.readLine()
            }
            result = response.toString()
            return result
        }

        override fun onPostExecute(result: String?) {
            super.onPostExecute(result)
            if (::flutterEngine.isInitialized) {
                Toast.makeText(this@MainActivity, result, Toast.LENGTH_LONG).show()
                MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("getDataResult", result.toString())
            }
        }
    }*/
}
