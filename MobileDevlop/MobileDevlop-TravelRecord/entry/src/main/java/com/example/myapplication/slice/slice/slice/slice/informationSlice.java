package com.example.myapplication.slice.slice.slice.slice;

import com.example.myapplication.ResourceTable;
import com.example.myapplication.slice.MainAbilitySlice;
import com.example.myapplication.slice.slice.slice.viewplanSlice;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;
import ohos.aafwk.content.Operation;
import ohos.agp.components.*;
import ohos.data.rdb.RdbPredicates;
import ohos.data.rdb.RdbStore;
import ohos.data.resultset.ResultSet;
import ohos.media.image.ImageSource;
import ohos.media.image.PixelMap;
import ohos.multimodalinput.event.TouchEvent;

import java.util.Vector;

public class informationSlice extends AbilitySlice {
    int id;
    RdbStore store;
    Image back;
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_information);
        back = findComponentById(ResourceTable.Id_inbk);
        back.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        back.setScaleX(0.8f);
                        back.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        back.setScaleX(1.0f);
                        back.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        back.setScaleX(1.0f);
                        back.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });

        id = getAbility().getIntent().getSerializableParam("id");
        store = MainAbilitySlice.store;
        int pm_px = AttrHelper.vp2px(getContext().getResourceManager().getDeviceCapability().width,this);
        String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
        RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",id);
        ResultSet resultSet = store.query(rdbPredicates,columns);
        resultSet.goToFirstRow();

        Text title = findComponentById(ResourceTable.Id_intitle);
        title.setText(resultSet.getString(6));
        int type = resultSet.getInt(1);
        Text date = findComponentById(ResourceTable.Id_indate);
        Text weather = findComponentById(ResourceTable.Id_inweather);
        Text sit = findComponentById(ResourceTable.Id_insitdes);

        if(type==0){
            date.setText("诗和远方在等你");
            weather.setText("阳光明媚");
            sit.setText(resultSet.getString(3));
        }
        else{
            date.setText(resultSet.getString(5));
            weather.setText(resultSet.getString(4));
            sit.setText(resultSet.getString(3));
        }

        Text des = findComponentById(ResourceTable.Id_indes);
        des.setText(resultSet.getString(7));
        DirectionalLayout addpic = findComponentById(ResourceTable.Id_inaddpic);
        viewplanSlice.singeldetail singeldetail = new viewplanSlice.singeldetail();

        singeldetail.setId(resultSet.getInt(0));
        singeldetail.setType(resultSet.getInt(1));
        singeldetail.setPicdes(resultSet.getString(2));
        singeldetail.setSitdes(resultSet.getString(3));
        singeldetail.setWeather(resultSet.getString(4));
        singeldetail.setDate(resultSet.getString(5));
        singeldetail.setTitle(resultSet.getString(6));
        singeldetail.setDes(resultSet.getString(7));
        singeldetail.setPicbytes(resultSet.getBlob(8));
        singeldetail.setCity(resultSet.getString(9));
        singeldetail.setLike(resultSet.getInt(10));

        Vector<PixelMap>cur_pic = getsingelpic(singeldetail);

        if(cur_pic.size()==0){
            Image onepic = new Image(this);
            onepic.setScaleMode(Image.ScaleMode.STRETCH);
            onepic.setHeight((int)(pm_px*0.9));onepic.setWidth((int)(pm_px*0.9));
            onepic.setMarginLeft((int)(pm_px*0.05));onepic.setMarginRight((int)(pm_px*0.05));
            onepic.setPixelMap(ResourceTable.Media_ma_3);//这里需要
            onepic.setCornerRadius(50);
        }
        else{
            for(int i=0;i<cur_pic.size();i++){
                Image image = new Image(this);
                image.setScaleMode(Image.ScaleMode.STRETCH);
                image.setWidth((int)(pm_px*0.9));
                image.setHeight((int)(pm_px*0.9));
                image.setMarginLeft((int)(pm_px*0.05));image.setMarginRight((int)(pm_px*0.05));
                image.setPixelMap(cur_pic.get(i));
                image.setMarginTop(15);
                image.setCornerRadius(50);
                addpic.addComponent(image);
            }
        }
        back.setClickedListener(new Component.ClickedListener() {
            @Override
            public void onClick(Component component) {
                if(type==1){
                    Intent i = new Intent();
                    Operation operation = new Intent.OperationBuilder()
                            .withDeviceId("")
                            .withBundleName("com.example.myapplication")
                            .withAbilityName("com.example.myapplication.slice.slice.slice.viewrec")
                            .build();
                    i.setOperation(operation);
                    startAbility(i);
                }else{
                    Intent i = new Intent();
                    Operation operation = new Intent.OperationBuilder()
                            .withDeviceId("")
                            .withBundleName("com.example.myapplication")
                            .withAbilityName("com.example.myapplication.slice.slice.viewplan")
                            .build();
                    i.setOperation(operation);
                    startAbility(i);
                }
            }
        });

    }
    public PixelMap bytetopix(byte[] bytes){
        ImageSource.SourceOptions sourceOptions = new ImageSource.SourceOptions();
        sourceOptions.formatHint="image/png";
        ImageSource imageSource = ImageSource.create(bytes,sourceOptions);
        PixelMap pixelMap = imageSource.createPixelmap(null);
        return pixelMap;
    }
    Vector<PixelMap> getsingelpic(viewplanSlice.singeldetail singeldetail){
        Vector<PixelMap> res = new Vector<PixelMap>();
        String picdes = singeldetail.getPicdes();
        byte[] picbytes = singeldetail.getPicbyte();
        String[] piclen = picdes.split(",");
        if(piclen.length==0||picdes.equals("")){
            return res;
        }
        else{
            int index=0;
            for(int i=0;i<piclen.length;i++){
                int cur_len = Integer.parseInt(piclen[i]);
                byte[] cur_byte = new byte[cur_len];
                for(int j=index;j<cur_len+index;j++){
                    cur_byte[j-index] = picbytes[j];
                }
                index+=cur_len;
                res.add(bytetopix(cur_byte));
            }
            return res;
        }
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
