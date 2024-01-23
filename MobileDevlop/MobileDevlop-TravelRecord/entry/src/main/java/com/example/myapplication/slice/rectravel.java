package com.example.myapplication.slice;

import com.example.myapplication.slice.slice.rectravelSlice;
import ohos.aafwk.ability.Ability;
import ohos.aafwk.content.Intent;

public class rectravel extends Ability {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setMainRoute(rectravelSlice.class.getName());
    }
}
