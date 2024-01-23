package com.example.myapplication;

import com.example.myapplication.slice.MainAbilitySlice;
import ohos.aafwk.ability.Ability;
import ohos.aafwk.content.Intent;
import ohos.agp.components.*;
import ohos.agp.components.element.FrameAnimationElement;
import ohos.rpc.RemoteException;

public class MainAbility extends Ability {
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setMainRoute(MainAbilitySlice.class.getName());
        try {
            String appId = getBundleManager().getBundleInfo(getBundleName(), 0).getAppId();
            System.out.println(appId);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
    }
}
