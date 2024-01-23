package com.example.myapplication.slice.slice.slice;

import com.amap.api.maps.model.particle.RandomVelocityBetweenTwoConstants;
import com.example.myapplication.ResourceTable;
import com.example.myapplication.slice.MainAbilitySlice;
import com.example.myapplication.slice.slice.slice.slice.viewrecSlice;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;
import ohos.aafwk.content.Operation;
import ohos.agp.components.DirectionalLayout;
import ohos.agp.components.Image;
import ohos.agp.components.element.PixelMapElement;
import ohos.agp.render.Region;
import ohos.agp.utils.LayoutAlignment;
import ohos.agp.window.dialog.CommonDialog;
import ohos.data.rdb.RdbPredicates;
import ohos.data.rdb.RdbStore;
import ohos.agp.components.*;
import ohos.data.rdb.ValuesBucket;
import ohos.data.resultset.ResultSet;
import ohos.global.resource.NotExistException;
import ohos.global.resource.Resource;
import ohos.media.image.ImageSource;
import ohos.media.image.PixelMap;
import ohos.multimodalinput.event.TouchEvent;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Vector;

public class viewplanSlice extends AbilitySlice implements Component.ClickedListener {
    RdbStore store;
    DirectionalLayout details;
    HashMap<DirectionalLayout,Integer> directionalLayoutIntegerHashMap;
    Image city,date;
    CommonDialog datecd,citycd;
    String curdate,curcity;
    Image choselike;
    Image back;
    int viewlike = 0;
    Vector<DirectionalLayout> cursin;
    public PixelMap bytetopix(byte[] bytes){
        ImageSource.SourceOptions sourceOptions = new ImageSource.SourceOptions();
        sourceOptions.formatHint="image/png";
        ImageSource imageSource = ImageSource.create(bytes,sourceOptions);
        PixelMap pixelMap = imageSource.createPixelmap(null);
        return pixelMap;
    }
    ValuesBucket getsinval(singeldetail singeldetail){
        ValuesBucket res = new ValuesBucket();
        res.putInteger("id",singeldetail.getId());
        res.putInteger("type",singeldetail.getType());
        res.putString("picdes",singeldetail.getPicdes());
        res.putString("sitdes",singeldetail.getSitdes());
        res.putString("weather",singeldetail.getWeather());
        res.putString("date",singeldetail.getDate());
        res.putString("title",singeldetail.getTitle());
        res.putString("des",singeldetail.getDes());
        res.putByteArray("picbyte",singeldetail.getPicbyte());
        res.putString("city",singeldetail.getCity());
        res.putInteger("like",singeldetail.getLike());
        return res;
    }
    Vector<PixelMap> getsingelpic(singeldetail singeldetail){
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

    void viewbydate(String seldate){
        cursin.clear();
        directionalLayoutIntegerHashMap.clear();
        details.removeAllComponents();
        directionalLayoutIntegerHashMap = new HashMap<DirectionalLayout,Integer>();

        int pm_px = AttrHelper.vp2px(getContext().getResourceManager().getDeviceCapability().width,this);
        Vector<singeldetail>vector = new Vector<singeldetail>();
        String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
        RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("date",seldate).equalTo("type",0).orderByDesc("date");
        ResultSet resultSet = store.query(rdbPredicates,columns);
        if(resultSet.getRowCount()!=0){
            resultSet.goToFirstRow();
            for(int i=0;i<resultSet.getRowCount();i++){
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
                vector.add(singeldetail);
                resultSet.goToNextRow();
            }
        }
        for(int i=0;i<vector.size();i++){
            DirectionalLayout directionalLayout = new DirectionalLayout(this);
            directionalLayout.setOrientation(Component.HORIZONTAL);
            directionalLayout.setWidth(pm_px);
            directionalLayout.setHeight(DirectionalLayout.LayoutConfig.MATCH_CONTENT);

            Text title = new Text(this);
            title.setText(vector.get(i).getTitle());
            title.setMultipleLine(false);
            title.setTextSize(90);
            title.setHeight(80);
            title.setWidth(250);
            title.setMaxTextLines(1);
            title.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            title.setMarginLeft(10);

            Text des = new Text(this);
            des.setText(vector.get(i).getDes());
            des.setHeight(70);
            des.setWidth(250);
            des.setTextSize(60);
            des.setMaxTextLines(2);
            des.setMultipleLine(true);
            des.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            des.setMarginLeft(10);

            Image issc = new Image(this);
            issc.setScaleMode(Image.ScaleMode.STRETCH);
            issc.setHeight(100);
            issc.setWidth(100);
            issc.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            issc.setScaleX(0.8f);
                            issc.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            issc.setScaleX(1.0f);
                            issc.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            issc.setScaleX(1.0f);
                            issc.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });

            if(vector.get(i).getLike()==1){
                issc.setPixelMap(ResourceTable.Media_like);
            }else{
                issc.setPixelMap(ResourceTable.Media_unlike);
            }
            int index = i;

            issc.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    if(vector.get(index).getLike()==1){
                        issc.setPixelMap(ResourceTable.Media_unlike);
                        String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
                        RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",vector.get(index).getId());
                        vector.get(index).setLike(0);
                        store.update(getsinval(vector.get(index)),rdbPredicates);
                    }else{
                        issc.setPixelMap(ResourceTable.Media_like);
                        String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
                        RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",vector.get(index).getId());
                        vector.get(index).setLike(1);
                        store.update(getsinval(vector.get(index)),rdbPredicates);
                    }
                }
            });
            Image det = new Image(this);
            det.setScaleMode(Image.ScaleMode.STRETCH);
            det.setHeight(100);
            det.setWidth(100);
            det.setPixelMap(ResourceTable.Media_det);
            det.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",vector.get(index).getId());
                    store.delete(rdbPredicates);
                    details.removeComponent(directionalLayout);
                    cursin.remove(directionalLayout);
                    directionalLayoutIntegerHashMap.remove(directionalLayout);
                }
            });
            det.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            det.setScaleX(0.8f);
                            det.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            det.setScaleX(1.0f);
                            det.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            det.setScaleX(1.0f);
                            det.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });

            DirectionalLayout leftdir = new DirectionalLayout(this);
            leftdir.setOrientation(Component.VERTICAL);
            leftdir.setWidth(300);
            leftdir.setHeight(300);
//            leftdir.setHeight(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
//            leftdir.setWidth(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
            issc.setMarginLeft(10);
            det.setMarginLeft(10);
            DirectionalLayout leftbottom = new DirectionalLayout(this);
            leftbottom.setOrientation(Component.HORIZONTAL);
            leftbottom.setWidth(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
            leftbottom.setHeight(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
            leftbottom.addComponent(issc);leftbottom.addComponent(det);
            leftbottom.setMarginTop(10);
            leftdir.addComponent(title);leftdir.addComponent(des);
            leftdir.addComponent(leftbottom);

            directionalLayout.addComponent(leftdir);

            //这里
            DirectionalLayout directionalLayout1 = new DirectionalLayout(this);
            directionalLayout1.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            directionalLayout1.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            directionalLayout1.setOrientation(Component.VERTICAL);
            Text date = new Text(this);
            date.setText(vector.get(i).getDate());
            date.setMultipleLine(false);
            date.setTextSize(60);
            date.setHeight(70);
            date.setWidth(400);
            date.setMaxTextLines(1);
            date.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            date.setMarginLeft(10);

            Text city = new Text(this);
            city.setText(vector.get(i).getCity());
            city.setMultipleLine(false);
            city.setTextSize(60);
            city.setHeight(70);
            city.setWidth(300);
            city.setMaxTextLines(1);
            city.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            city.setMarginLeft(10);
            directionalLayout1.addComponent(date);
            directionalLayout1.addComponent(city);
            //结束

            directionalLayout.addComponent(directionalLayout1);

            Image showpic = new Image(this);
            showpic.setWidth(300);
            showpic.setScaleMode(Image.ScaleMode.STRETCH);
            showpic.setHeight(300);
//            showpic.setMarginLeft(260);
            showpic.setCornerRadius(50);

            Vector<PixelMap> cur_pic = getsingelpic(vector.get(i));

            if(cur_pic.size()==0){
                showpic.setPixelMap(ResourceTable.Media_ma_3);
            }else{
                showpic.setPixelMap(cur_pic.get(0));
            }

            directionalLayout.addComponent(showpic);
            directionalLayout.setMarginTop(10);
            details.addComponent(directionalLayout);

            Image line = new Image(this);
            line.setPixelMap(ResourceTable.Media_line);
            line.setWidth(pm_px);
            line.setHeight(3);
            line.setScaleMode(Image.ScaleMode.STRETCH);
            details.addComponent(line);

            cursin.add(directionalLayout);
            directionalLayout.setClickedListener(this);

            directionalLayoutIntegerHashMap.put(directionalLayout,vector.get(i).getId());
        }
    }
    void viewbycity(String city){
        cursin.clear();
        directionalLayoutIntegerHashMap.clear();
        details.removeAllComponents();
        directionalLayoutIntegerHashMap = new HashMap<DirectionalLayout,Integer>();

        int pm_px = AttrHelper.vp2px(getContext().getResourceManager().getDeviceCapability().width,this);
        Vector<singeldetail>vector = new Vector<singeldetail>();
        String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
        RdbPredicates rdbPredicates = new RdbPredicates("test").beginsWith("city",city).equalTo("type",0).orderByDesc("date");
        ResultSet resultSet = store.query(rdbPredicates,columns);
        if(resultSet.getRowCount()!=0){
            resultSet.goToFirstRow();
            for(int i=0;i<resultSet.getRowCount();i++){
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
                vector.add(singeldetail);
                resultSet.goToNextRow();
            }
        }
        for(int i=0;i<vector.size();i++){
            DirectionalLayout directionalLayout = new DirectionalLayout(this);
            directionalLayout.setOrientation(Component.HORIZONTAL);
            directionalLayout.setWidth(pm_px);
            directionalLayout.setHeight(DirectionalLayout.LayoutConfig.MATCH_CONTENT);

            Text title = new Text(this);
            title.setText(vector.get(i).getTitle());
            title.setMultipleLine(false);
            title.setTextSize(90);
            title.setHeight(80);
            title.setWidth(250);
            title.setMaxTextLines(1);
            title.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            title.setMarginLeft(10);

            Text des = new Text(this);
            des.setText(vector.get(i).getDes());
            des.setHeight(70);
            des.setWidth(250);
            des.setTextSize(60);
            des.setMaxTextLines(2);
            des.setMultipleLine(true);
            des.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            des.setMarginLeft(10);

            Image issc = new Image(this);
            issc.setScaleMode(Image.ScaleMode.STRETCH);
            issc.setHeight(100);
            issc.setWidth(100);
            issc.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            issc.setScaleX(0.8f);
                            issc.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            issc.setScaleX(1.0f);
                            issc.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            issc.setScaleX(1.0f);
                            issc.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });

            if(vector.get(i).getLike()==1){
                issc.setPixelMap(ResourceTable.Media_like);
            }else{
                issc.setPixelMap(ResourceTable.Media_unlike);
            }
            int index = i;

            issc.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    if(vector.get(index).getLike()==1){
                        issc.setPixelMap(ResourceTable.Media_unlike);
                        String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
                        RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",vector.get(index).getId());
                        vector.get(index).setLike(0);
                        store.update(getsinval(vector.get(index)),rdbPredicates);
                    }else{
                        issc.setPixelMap(ResourceTable.Media_like);
                        String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
                        RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",vector.get(index).getId());
                        vector.get(index).setLike(1);
                        store.update(getsinval(vector.get(index)),rdbPredicates);
                    }
                }
            });
            Image det = new Image(this);
            det.setScaleMode(Image.ScaleMode.STRETCH);
            det.setHeight(100);
            det.setWidth(100);
            det.setPixelMap(ResourceTable.Media_det);
            det.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",vector.get(index).getId());
                    store.delete(rdbPredicates);
                    details.removeComponent(directionalLayout);
                    cursin.remove(directionalLayout);
                    directionalLayoutIntegerHashMap.remove(directionalLayout);
                }
            });
            det.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            det.setScaleX(0.8f);
                            det.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            det.setScaleX(1.0f);
                            det.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            det.setScaleX(1.0f);
                            det.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });

            DirectionalLayout leftdir = new DirectionalLayout(this);
            leftdir.setOrientation(Component.VERTICAL);
            leftdir.setWidth(300);
            leftdir.setHeight(300);
//            leftdir.setHeight(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
//            leftdir.setWidth(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
            issc.setMarginLeft(10);
            det.setMarginLeft(10);
            DirectionalLayout leftbottom = new DirectionalLayout(this);
            leftbottom.setOrientation(Component.HORIZONTAL);
            leftbottom.setWidth(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
            leftbottom.setHeight(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
            leftbottom.addComponent(issc);leftbottom.addComponent(det);
            leftbottom.setMarginTop(10);
            leftdir.addComponent(title);leftdir.addComponent(des);
            leftdir.addComponent(leftbottom);

            directionalLayout.addComponent(leftdir);

            //这里
            DirectionalLayout directionalLayout1 = new DirectionalLayout(this);
            directionalLayout1.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            directionalLayout1.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            directionalLayout1.setOrientation(Component.VERTICAL);
            Text date = new Text(this);
            date.setText(vector.get(i).getDate());
            date.setMultipleLine(false);
            date.setTextSize(60);
            date.setHeight(70);
            date.setWidth(400);
            date.setMaxTextLines(1);
            date.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            date.setMarginLeft(10);

            Text city_1 = new Text(this);
            city_1.setText(vector.get(i).getCity());
            city_1.setMultipleLine(false);
            city_1.setTextSize(60);
            city_1.setHeight(70);
            city_1.setWidth(300);
            city_1.setMaxTextLines(1);
            city_1.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            city_1.setMarginLeft(10);
            directionalLayout1.addComponent(date);
            directionalLayout1.addComponent(city_1);
            //结束

            directionalLayout.addComponent(directionalLayout1);

            Image showpic = new Image(this);
            showpic.setWidth(300);
            showpic.setScaleMode(Image.ScaleMode.STRETCH);
            showpic.setHeight(300);
//            showpic.setMarginLeft(260);
            showpic.setCornerRadius(50);

            Vector<PixelMap> cur_pic = getsingelpic(vector.get(i));

            if(cur_pic.size()==0){
                showpic.setPixelMap(ResourceTable.Media_ma_3);
            }else{
                showpic.setPixelMap(cur_pic.get(0));
            }

            directionalLayout.addComponent(showpic);
            directionalLayout.setMarginTop(10);
            details.addComponent(directionalLayout);

            Image line = new Image(this);
            line.setPixelMap(ResourceTable.Media_line);
            line.setWidth(pm_px);
            line.setHeight(3);
            line.setScaleMode(Image.ScaleMode.STRETCH);
            details.addComponent(line);

            cursin.add(directionalLayout);
            directionalLayout.setClickedListener(this);

            directionalLayoutIntegerHashMap.put(directionalLayout,vector.get(i).getId());
        }
    }
    void viewbylike(int islike){
        cursin.clear();
        directionalLayoutIntegerHashMap.clear();
        details.removeAllComponents();
        directionalLayoutIntegerHashMap = new HashMap<DirectionalLayout,Integer>();

        int pm_px = AttrHelper.vp2px(getContext().getResourceManager().getDeviceCapability().width,this);
        Vector<singeldetail>vector = new Vector<singeldetail>();
        String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
        RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("like",islike).equalTo("type",0).orderByDesc("date");
        ResultSet resultSet = store.query(rdbPredicates,columns);
        if(resultSet.getRowCount()!=0){
            resultSet.goToFirstRow();
            for(int i=0;i<resultSet.getRowCount();i++){
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
                vector.add(singeldetail);
                resultSet.goToNextRow();
            }
        }
        for(int i=0;i<vector.size();i++){
            DirectionalLayout directionalLayout = new DirectionalLayout(this);
            directionalLayout.setOrientation(Component.HORIZONTAL);
            directionalLayout.setWidth(pm_px);
            directionalLayout.setHeight(DirectionalLayout.LayoutConfig.MATCH_CONTENT);

            Text title = new Text(this);
            title.setText(vector.get(i).getTitle());
            title.setMultipleLine(false);
            title.setTextSize(90);
            title.setHeight(80);
            title.setWidth(250);
            title.setMaxTextLines(1);
            title.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            title.setMarginLeft(10);

            Text des = new Text(this);
            des.setText(vector.get(i).getDes());
            des.setHeight(70);
            des.setWidth(250);
            des.setTextSize(60);
            des.setMaxTextLines(2);
            des.setMultipleLine(true);
            des.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            des.setMarginLeft(10);

            Image issc = new Image(this);
            issc.setScaleMode(Image.ScaleMode.STRETCH);
            issc.setHeight(100);
            issc.setWidth(100);
            issc.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            issc.setScaleX(0.8f);
                            issc.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            issc.setScaleX(1.0f);
                            issc.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            issc.setScaleX(1.0f);
                            issc.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });

            if(vector.get(i).getLike()==1){
                issc.setPixelMap(ResourceTable.Media_like);
            }else{
                issc.setPixelMap(ResourceTable.Media_unlike);
            }
            int index = i;

            issc.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    if(vector.get(index).getLike()==1){
                        issc.setPixelMap(ResourceTable.Media_unlike);
                        String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
                        RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",vector.get(index).getId());
                        vector.get(index).setLike(0);
                        store.update(getsinval(vector.get(index)),rdbPredicates);
                    }else{
                        issc.setPixelMap(ResourceTable.Media_like);
                        String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
                        RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",vector.get(index).getId());
                        vector.get(index).setLike(1);
                        store.update(getsinval(vector.get(index)),rdbPredicates);
                    }
                }
            });
            Image det = new Image(this);
            det.setScaleMode(Image.ScaleMode.STRETCH);
            det.setHeight(100);
            det.setWidth(100);
            det.setPixelMap(ResourceTable.Media_det);
            det.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",vector.get(index).getId());
                    store.delete(rdbPredicates);
                    details.removeComponent(directionalLayout);
                    cursin.remove(directionalLayout);
                    directionalLayoutIntegerHashMap.remove(directionalLayout);
                }
            });
            det.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            det.setScaleX(0.8f);
                            det.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            det.setScaleX(1.0f);
                            det.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            det.setScaleX(1.0f);
                            det.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });

            DirectionalLayout leftdir = new DirectionalLayout(this);
            leftdir.setOrientation(Component.VERTICAL);
            leftdir.setWidth(300);
            leftdir.setHeight(300);
//            leftdir.setHeight(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
//            leftdir.setWidth(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
            issc.setMarginLeft(10);
            det.setMarginLeft(10);
            DirectionalLayout leftbottom = new DirectionalLayout(this);
            leftbottom.setOrientation(Component.HORIZONTAL);
            leftbottom.setWidth(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
            leftbottom.setHeight(DirectionalLayout.LayoutConfig.MATCH_CONTENT);
            leftbottom.addComponent(issc);leftbottom.addComponent(det);
            leftbottom.setMarginTop(10);
            leftdir.addComponent(title);leftdir.addComponent(des);
            leftdir.addComponent(leftbottom);

            directionalLayout.addComponent(leftdir);

            //这里
            DirectionalLayout directionalLayout1 = new DirectionalLayout(this);
            directionalLayout1.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            directionalLayout1.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            directionalLayout1.setOrientation(Component.VERTICAL);
            Text date = new Text(this);
            date.setText(vector.get(i).getDate());
            date.setMultipleLine(false);
            date.setTextSize(60);
            date.setHeight(70);
            date.setWidth(400);
            date.setMaxTextLines(1);
            date.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            date.setMarginLeft(10);

            Text city = new Text(this);
            city.setText(vector.get(i).getCity());
            city.setMultipleLine(false);
            city.setTextSize(60);
            city.setHeight(70);
            city.setWidth(300);
            city.setMaxTextLines(1);
            city.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
            city.setMarginLeft(10);
            directionalLayout1.addComponent(date);
            directionalLayout1.addComponent(city);
            //结束

            directionalLayout.addComponent(directionalLayout1);

            Image showpic = new Image(this);
            showpic.setWidth(300);
            showpic.setScaleMode(Image.ScaleMode.STRETCH);
            showpic.setHeight(300);
//            showpic.setMarginLeft(260);
            showpic.setCornerRadius(50);

            Vector<PixelMap> cur_pic = getsingelpic(vector.get(i));

            if(cur_pic.size()==0){
                showpic.setPixelMap(ResourceTable.Media_ma_3);
            }else{
                showpic.setPixelMap(cur_pic.get(0));
            }

            directionalLayout.addComponent(showpic);
            directionalLayout.setMarginTop(10);
            details.addComponent(directionalLayout);

            Image line = new Image(this);
            line.setPixelMap(ResourceTable.Media_line);
            line.setWidth(pm_px);
            line.setHeight(3);
            line.setScaleMode(Image.ScaleMode.STRETCH);
            details.addComponent(line);

            cursin.add(directionalLayout);
            directionalLayout.setClickedListener(this);

            directionalLayoutIntegerHashMap.put(directionalLayout,vector.get(i).getId());
        }
    }
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_viewplan);
        back = findComponentById(ResourceTable.Id_back);
        back.setClickedListener(this);
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

        cursin = new Vector<DirectionalLayout>();
        directionalLayoutIntegerHashMap = new HashMap<DirectionalLayout, Integer>();
        details = findComponentById(ResourceTable.Id_details);
        store = MainAbilitySlice.store;

        date = findComponentById(ResourceTable.Id_date);
        city = findComponentById(ResourceTable.Id_city);
        date.setClickedListener(this);
        city.setClickedListener(this);
        date.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        date.setScaleX(0.8f);
                        date.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        date.setScaleX(1.0f);
                        date.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        date.setScaleX(1.0f);
                        date.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });
        city.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        city.setScaleX(0.8f);
                        city.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        city.setScaleX(1.0f);
                        city.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        city.setScaleX(1.0f);
                        city.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });

        SimpleDateFormat sdf = new SimpleDateFormat();
        sdf.applyPattern("yyyy-MM-dd HH:mm:ss a");//a为am/pm标记
        Date date = new Date();
//        System.out.println("现在时间: " + sdf.format(date));
        int day = Integer.parseInt(String.valueOf(sdf.format(date).substring(8,10)));
        int month = Integer.parseInt(String.valueOf(sdf.format(date).substring(5,7)));
        int year = Integer.parseInt(String.valueOf(sdf.format(date).substring(0,4)));
        curdate = String.valueOf(year)+"-"+String.valueOf(month)+"-"+String.valueOf(day);

        choselike = findComponentById(ResourceTable.Id_like);
        choselike.setClickedListener(this);
        choselike.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        choselike.setScaleX(0.8f);
                        choselike.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        choselike.setScaleX(1.0f);
                        choselike.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        choselike.setScaleX(1.0f);
                        choselike.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });

        System.out.println(curdate);
        viewbydate(curdate);

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
        if(component==date){
            int pm_px = AttrHelper.vp2px(getContext().getResourceManager().getDeviceCapability().width,this);
            DirectionalLayout seldate = new DirectionalLayout(this);
            seldate.setOrientation(Component.VERTICAL);
//            seldate.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            seldate.setHeight(1900);
            seldate.setWidth(pm_px);
            try{
                Resource resource = getResourceManager().getResource(ResourceTable.Media_date_pick);//这里需要Media_recbk
                PixelMapElement pixelMapElement = new PixelMapElement(resource);
                seldate.setBackground(pixelMapElement);
            } catch (IOException e){
                e.printStackTrace();
            } catch (NotExistException e){
                e.printStackTrace();
            }

            Image datecancel = new Image(this);
            datecancel.setPixelMap(ResourceTable.Media_cancel);//这里需要Media_cancel
            datecancel.setScaleMode(Image.ScaleMode.STRETCH);
            datecancel.setWidth((int)(pm_px*0.15));datecancel.setHeight((int)(pm_px*0.15));
            datecancel.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            datecancel.setScaleX(0.8f);
                            datecancel.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            datecancel.setScaleX(1.0f);
                            datecancel.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            datecancel.setScaleX(1.0f);
                            datecancel.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });

            Image dateconfirm = new Image(this);
            dateconfirm.setPixelMap(ResourceTable.Media_confirm);//这里需要Media_confirm
            dateconfirm.setScaleMode(Image.ScaleMode.STRETCH);
            dateconfirm.setWidth((int)(pm_px*0.15));datecancel.setHeight((int)(pm_px*0.15));
            dateconfirm.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            dateconfirm.setScaleX(0.8f);
                            dateconfirm.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            dateconfirm.setScaleX(1.0f);
                            dateconfirm.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            dateconfirm.setScaleX(1.0f);
                            dateconfirm.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });

            DirectionalLayout firstline = new DirectionalLayout(this);
            firstline.setWidth(pm_px);firstline.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            firstline.setOrientation(Component.HORIZONTAL);

            datecancel.setMarginLeft((int)(pm_px*0.7));
            firstline.addComponent(dateconfirm);firstline.addComponent(datecancel);

            DatePicker datePicker = new DatePicker(this);
            datePicker.setWidth(pm_px);
            datePicker.setHeight(pm_px);
            datePicker.setNormalTextSize(80);
            datePicker.setSelectedTextSize(100);
            datePicker.setNormalTextColor(ohos.agp.utils.Color.GRAY);
            datePicker.setSelectedTextColor(ohos.agp.utils.Color.GREEN);
            datePicker.setMarginTop(10);

            seldate.addComponent(firstline);
            seldate.addComponent(datePicker);

            datecd = new CommonDialog(this.getContext());
            datecd.setAlignment(LayoutAlignment.BOTTOM);
            datecd.setCornerRadius(30);
            datecd.setContentCustomComponent(seldate);
            datecd.show();
            datecancel.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    datecd.destroy();
                }
            });
            dateconfirm.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    String year = String.valueOf(datePicker.getYear());
                    String month = String.valueOf(datePicker.getMonth());
                    String day = String.valueOf(datePicker.getDayOfMonth());
                    curdate = year+"-"+month+"-"+day;
                    viewbydate(curdate);
                    datecd.destroy();
                }
            });
        }
        else if(component==city){
            int pm_px = AttrHelper.vp2px(getContext().getResourceManager().getDeviceCapability().width,this);
            DirectionalLayout seldate = new DirectionalLayout(this);
            seldate.setOrientation(Component.VERTICAL);
//            seldate.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            seldate.setHeight(1900);
            seldate.setWidth(pm_px);
            try{
                Resource resource = getResourceManager().getResource(ResourceTable.Media_city_pick);//这里需要Media_recbk
                PixelMapElement pixelMapElement = new PixelMapElement(resource);
                seldate.setBackground(pixelMapElement);
            } catch (IOException e){
                e.printStackTrace();
            } catch (NotExistException e){
                e.printStackTrace();
            }
            Image datecancel = new Image(this);
            datecancel.setPixelMap(ResourceTable.Media_cancel);//这里需要Media_cancel
            datecancel.setScaleMode(Image.ScaleMode.STRETCH);
            datecancel.setWidth((int)(pm_px*0.15));datecancel.setHeight((int)(pm_px*0.15));
            datecancel.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            datecancel.setScaleX(0.8f);
                            datecancel.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            datecancel.setScaleX(1.0f);
                            datecancel.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            datecancel.setScaleX(1.0f);
                            datecancel.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });

            Image dateconfirm = new Image(this);
            dateconfirm.setPixelMap(ResourceTable.Media_confirm);//这里需要Media_confirm
            dateconfirm.setScaleMode(Image.ScaleMode.STRETCH);
            dateconfirm.setWidth((int)(pm_px*0.15));datecancel.setHeight((int)(pm_px*0.15));
            dateconfirm.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            dateconfirm.setScaleX(0.8f);
                            dateconfirm.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            dateconfirm.setScaleX(1.0f);
                            dateconfirm.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            dateconfirm.setScaleX(1.0f);
                            dateconfirm.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });

            DirectionalLayout firstline = new DirectionalLayout(this);
            firstline.setWidth(pm_px);firstline.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            firstline.setOrientation(Component.HORIZONTAL);

            datecancel.setMarginLeft((int)(pm_px*0.7));
            firstline.addComponent(dateconfirm);firstline.addComponent(datecancel);

            Picker citypicker = new Picker(this);
            citypicker.setWidth(pm_px);
            citypicker.setHeight(pm_px);
            citypicker.setNormalTextSize(80);
            citypicker.setSelectedTextSize(100);
            citypicker.setNormalTextColor(ohos.agp.utils.Color.GRAY);
            citypicker.setSelectedTextColor(ohos.agp.utils.Color.BLUE);
            citypicker.setMarginTop(10);
            seldate.addComponent(firstline);
            citypicker.setMinValue(0);
            citypicker.setMaxValue(34);
            String[] citylist = new String[]{"定位","北京","天津","河北","内蒙古","上海","重庆","黑龙江","吉林","辽宁","新疆","甘肃",
                    "青海","陕西","宁夏","河南","山东","山西","安徽","湖北","湖南","江苏","四川","贵州","云南","广西","西藏","浙江","江西","广东","福建","台湾","海南","香港","澳门"};
            citypicker.setDisplayedData(citylist);
            citypicker.setValueChangedListener(new Picker.ValueChangedListener() {
                @Override
                public void onValueChanged(Picker picker, int i, int i1) {
                    curcity = citylist[i1];
                }
            });
            seldate.addComponent(citypicker);
            citycd = new CommonDialog(this.getContext());
            citycd.setAlignment(LayoutAlignment.BOTTOM);
            citycd.setCornerRadius(30);
            citycd.setContentCustomComponent(seldate);
            citycd.show();
            datecancel.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    citycd.destroy();
                }
            });
            dateconfirm.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    System.out.println(curcity);
                    viewbycity(curcity);
                    citycd.destroy();
                }
            });
        }
        else if(component==choselike){
            if(viewlike==0){
                viewlike=1;
                choselike.setPixelMap(ResourceTable.Media_like);//这里需要 Media_likeed
                viewbylike(viewlike);
            }
            else{
                viewlike=0;
                choselike.setPixelMap(ResourceTable.Media_unlike);
                viewbylike(viewlike);
            }
        }
        else if(component==back){
            Intent i = new Intent();
            Operation operation = new Intent.OperationBuilder()
                    .withDeviceId("")
                    .withBundleName("com.example.myapplication")
                    .withAbilityName("com.example.myapplication.MainAbility")
                    .build();
            i.setOperation(operation);
            startAbility(i);
        }
        else if(cursin.contains(component)){
            Intent i = new Intent();
            Operation operation = new Intent.OperationBuilder()
                    .withDeviceId("")
                    .withBundleName("com.example.myapplication")
                    .withAbilityName("com.example.myapplication.slice.slice.slice.information")//TODO
                    .build();
            i.setParam("id",directionalLayoutIntegerHashMap.get(component));
            i.setOperation(operation);
            startAbility(i);
        }

    }
    public static class singeldetail{
        int id,type;
        String picdes,sitdes,weather,date,title,des,city;
        int like;
        byte[] picbyte;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public int getType() {
            return type;
        }

        public void setType(int type) {
            this.type = type;
        }

        public String getPicdes() {
            return picdes;
        }

        public void setPicdes(String picdes) {
            this.picdes = picdes;
        }

        public String getSitdes() {
            return sitdes;
        }

        public void setSitdes(String sitdes) {
            this.sitdes = sitdes;
        }

        public String getWeather() {
            return weather;
        }

        public void setWeather(String weather) {
            this.weather = weather;
        }

        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getDes() {
            return des;
        }

        public void setDes(String des) {
            this.des = des;
        }

        public String getCity() {
            return city;
        }

        public void setCity(String city) {
            this.city = city;
        }

        public int getLike() {
            return like;
        }

        public void setLike(int like) {
            this.like = like;
        }

        public byte[] getPicbyte() {
            return picbyte;
        }

        public void setPicbytes(byte[] picbyte) {
            this.picbyte = picbyte;
        }
    }
}
