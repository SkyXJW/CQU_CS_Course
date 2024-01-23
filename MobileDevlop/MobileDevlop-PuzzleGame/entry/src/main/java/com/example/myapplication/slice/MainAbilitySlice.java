package com.example.myapplication.slice;

import com.example.myapplication.ResourceTable;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;
import ohos.agp.components.Button;
import ohos.agp.components.Component;

public class MainAbilitySlice extends AbilitySlice implements Component.ClickedListener {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_ability_main);
        Button btn_play = findComponentById(ResourceTable.Id_play);
        Button btn_info = findComponentById(ResourceTable.Id_info);
        Button btn_help = findComponentById(ResourceTable.Id_help);
        btn_play.setClickedListener(this);
        btn_info.setClickedListener(this);
        btn_help.setClickedListener(this);
    }

    @Override
    public void onActive() {
        super.onActive();
    }

    @Override
    public void onForeground(Intent intent) {
        super.onForeground(intent);
    }

    @Override
    public void onClick(Component component) {
        //设置点击事件，逻辑很简单，即跳转到对应页面即可
        if(component.getId()==ResourceTable.Id_play){
            Intent intent1 = new Intent();
            AbilitySlice slice = new game1Slice();
            present(slice, intent1);
        }else if(component.getId()==ResourceTable.Id_info){
            Intent intent1 = new Intent();
            AbilitySlice slice = new authorSlice();
            present(slice, intent1);
        }else if(component.getId()==ResourceTable.Id_help){
            Intent intent1 = new Intent();
            AbilitySlice slice = new ruleSlice();
            present(slice, intent1);
        }
    }
}
