package com.example.myapplication.slice;

import com.example.myapplication.ResourceTable;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;
import ohos.aafwk.content.Operation;
import ohos.agp.components.*;
import ohos.agp.components.element.FrameAnimationElement;
import ohos.data.DatabaseHelper;
import ohos.data.rdb.RdbOpenCallback;
import ohos.data.rdb.RdbStore;
import ohos.data.rdb.StoreConfig;
import ohos.multimodalinput.event.TouchEvent;
import ohos.rpc.RemoteException;

public class MainAbilitySlice extends AbilitySlice {
    public static RdbStore store;
    DatabaseHelper helper;
    StoreConfig config;
    RdbOpenCallback callback;
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_ability_main);
        try {
            String appId = getBundleManager().getBundleInfo(getBundleName(), 0).getAppId();
            System.out.println(appId);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }
//        Text xz = (Text) findComponentById(ResourceTable.Id_tobuild);
//        Text ck = (Text) findComponentById(ResourceTable.Id_toview);
//        Text pl = (Text) findComponentById(ResourceTable.Id_toplan);
        Image xz_pic = findComponentById(ResourceTable.Id_tobuild_pic);
        Image ck_pic = findComponentById(ResourceTable.Id_toview_pic);
        Image pl_pic = findComponentById(ResourceTable.Id_toplan_pic);

        helper = new DatabaseHelper(this);
        config = StoreConfig.newDefaultConfig("RdbStoreTest.db");
        callback = new RdbOpenCallback() {
            @Override
            public void onCreate(RdbStore rdbStore) {
                rdbStore.executeSql("CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT,type Integer,picdes TEXT,sitdes TEXT,weather TEXT,date TEXT,title TEXT,des TEXT,picbyte BLOB,city TEXT,like INTEGER)");
            }
            @Override
            public void onUpgrade(RdbStore rdbStore, int i, int i1) {

            }
        };
        xz_pic.setClickedListener(new Component.ClickedListener() {
            @Override
            public void onClick(Component component) {
                Intent i = new Intent();
                Operation operation = new Intent.OperationBuilder()
                        .withDeviceId("")
                        .withBundleName("com.example.myapplication")
                        .withAbilityName("com.example.myapplication.slice.rectravel")
                        .build();
                i.setOperation(operation);
                startAbility(i);
            }
        });
        xz_pic.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        xz_pic.setScaleX(0.8f);
                        xz_pic.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        xz_pic.setScaleX(1.0f);
                        xz_pic.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        xz_pic.setScaleX(1.0f);
                        xz_pic.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });
        store = helper.getRdbStore(config,1,callback,null);
        ck_pic.setClickedListener(new Component.ClickedListener() {
            @Override
            public void onClick(Component component) {
                Intent i = new Intent();
                Operation operation = new Intent.OperationBuilder()
                        .withDeviceId("")
                        .withBundleName("com.example.myapplication")
                        .withAbilityName("com.example.myapplication.slice.slice.slice.viewrec")
                        .build();
                i.setOperation(operation);
                startAbility(i);
            }
        });
        ck_pic.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        ck_pic.setScaleX(0.8f);
                        ck_pic.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        ck_pic.setScaleX(1.0f);
                        ck_pic.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        ck_pic.setScaleX(1.0f);
                        ck_pic.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });
        pl_pic.setClickedListener(new Component.ClickedListener() {
            @Override
            public void onClick(Component component) {
                Intent i = new Intent();
                Operation operation = new Intent.OperationBuilder()
                        .withDeviceId("")
                        .withBundleName("com.example.myapplication")
                        .withAbilityName("com.example.myapplication.slice.slice.viewplan")
                        .build();
                i.setOperation(operation);
                startAbility(i);
            }
        });
        pl_pic.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        pl_pic.setScaleX(0.8f);
                        pl_pic.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        pl_pic.setScaleX(1.0f);
                        pl_pic.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        pl_pic.setScaleX(1.0f);
                        pl_pic.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });
        FrameAnimationElement frameAnimationElement_ma = new FrameAnimationElement(getContext(),ResourceTable.Graphic_main_bk);
        DirectionalLayout directionalLayout_ma = findComponentById(ResourceTable.Id_main);
        directionalLayout_ma.setBackground(frameAnimationElement_ma);
        frameAnimationElement_ma.start();

        FrameAnimationElement frameAnimationElement = new FrameAnimationElement(getContext(),ResourceTable.Graphic_animation_ele);
        Image image = new Image(getContext());
        image.setLayoutConfig(new ComponentContainer.LayoutConfig(1250,700));
        image.setBackground(frameAnimationElement);
        image.setHeight(150);
        image.setWidth(150);
        image.setScaleMode(Image.ScaleMode.INSIDE);
        image.setCornerRadius(50);
        DirectionalLayout directionalLayout = findComponentById(ResourceTable.Id_frame);
        directionalLayout.addComponent(image);
        frameAnimationElement.start();
    }

    @Override
    public void onActive() {
        super.onActive();
    }

    @Override
    public void onForeground(Intent intent) {
        super.onForeground(intent);
    }
}
