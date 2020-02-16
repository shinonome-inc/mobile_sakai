package dotinstall.com

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View

import kotlinx.android.synthetic.main.activity_main.*


class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    fun changetextview(view: View) {
        var year = this.year_number.text.toString().toInt()

        if (year%4 == 0 && year%100 != 0 || year%400 == 0)
            messageTextview.text = "$year is leapyear"
        else
            messageTextview.text = "$year is not leapyear"
    }
}
