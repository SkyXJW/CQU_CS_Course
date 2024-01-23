package com.example.myapplication;

import com.example.myapplication.slice.ruleSlice;
import ohos.aafwk.ability.Ability;
import ohos.aafwk.content.Intent;

public class rule extends Ability {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setMainRoute(ruleSlice.class.getName());
    }
}
