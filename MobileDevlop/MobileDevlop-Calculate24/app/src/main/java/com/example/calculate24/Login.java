package com.example.calculate24;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewPropertyAnimator;
import android.widget.Button;
import android.widget.ImageView;

public class Login extends AppCompatActivity implements View.OnClickListener,View.OnTouchListener{
    private Button btn_play;
    private ImageView question;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        btn_play = findViewById(R.id.btn_play);
        btn_play.setOnClickListener(this);
        question = findViewById(R.id.question);
        question.setOnClickListener(this);
        question.setOnTouchListener(this);
    }

    @Override
    public void onClick(View view) {
        if(view.getId()==R.id.btn_play){
            startActivity(new Intent(this, MainActivity.class));
            finish();
        }else if(view.getId()==R.id.question){
            startActivity(new Intent(this, question.class));
        }
    }

    @Override
    public boolean onTouch(View view, MotionEvent motionEvent) {
        ViewPropertyAnimator animator;
        switch (motionEvent.getAction()) {
            case MotionEvent.ACTION_DOWN:
                // 用户按下按钮时，开始缩小动画
                animator = view.animate()
                        .scaleX(0.2f)
                        .scaleY(0.2f);
                animator.start();
                break;
            case MotionEvent.ACTION_UP:
                // 用户松开按钮时，开始回弹动画
                animator = view.animate()
                        .scaleX(1.0f)
                        .scaleY(1.0f);
                animator.start();
                break;
        }
        return false;
    }
}