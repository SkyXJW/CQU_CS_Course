package com.example.myapplication.slice.slice;

import com.example.myapplication.slice.slice.slice.viewplanSlice;
import ohos.aafwk.ability.Ability;
import ohos.aafwk.content.Intent;

public class viewplan extends Ability {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setMainRoute(viewplanSlice.class.getName());
    }
}
