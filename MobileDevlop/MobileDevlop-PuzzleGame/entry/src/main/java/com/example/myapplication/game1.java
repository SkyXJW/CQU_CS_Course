package com.example.myapplication;

import com.example.myapplication.slice.game1Slice;
import ohos.aafwk.ability.Ability;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;

public class game1 extends Ability {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setMainRoute(game1Slice.class.getName());
    }
}
