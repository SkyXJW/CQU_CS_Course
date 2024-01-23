package com.example.myapplication.slice.slice.slice;

import com.example.myapplication.slice.slice.slice.slice.viewrecSlice;
import ohos.aafwk.ability.Ability;
import ohos.aafwk.content.Intent;

public class viewrec extends Ability {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setMainRoute(viewrecSlice.class.getName());
    }
}
