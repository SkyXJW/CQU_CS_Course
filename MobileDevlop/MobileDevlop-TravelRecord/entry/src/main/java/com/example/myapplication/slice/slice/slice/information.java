package com.example.myapplication.slice.slice.slice;

import com.example.myapplication.slice.slice.slice.slice.informationSlice;
import ohos.aafwk.ability.Ability;
import ohos.aafwk.content.Intent;

public class information extends Ability {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setMainRoute(informationSlice.class.getName());
    }
}
