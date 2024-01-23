package com.example.myapplication.slice.slice;

import com.amap.adapter.graphics.Color;
import com.amap.adapter.view.GestureDetector;
import com.amap.adapter.view.MotionEvent;
import com.amap.api.maps.*;
import com.amap.api.maps.model.CameraPosition;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.MyLocationStyle;
import com.example.myapplication.ResourceTable;
import com.example.myapplication.slice.MainAbilitySlice;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.ability.DataAbilityHelper;
import ohos.aafwk.ability.DataAbilityRemoteException;
import ohos.aafwk.content.Intent;
import ohos.aafwk.content.Operation;
import ohos.agp.components.*;
import ohos.agp.components.element.PixelMapElement;
import ohos.agp.components.flex.AlignContent;
import ohos.agp.utils.LayoutAlignment;
import ohos.agp.window.dialog.CommonDialog;
import ohos.agp.window.dialog.ToastDialog;
import ohos.data.rdb.RdbPredicates;
import ohos.data.rdb.RdbStore;
import ohos.data.rdb.ValuesBucket;
import ohos.data.resultset.ResultSet;
import ohos.global.resource.NotExistException;
import ohos.global.resource.Resource;
import ohos.location.*;
import ohos.media.image.ImagePacker;
import ohos.media.image.ImageSource;
import ohos.media.image.PixelMap;
import ohos.media.photokit.metadata.AVStorage;
import ohos.multimodalinput.event.TouchEvent;
import ohos.utils.net.Uri;

import javax.net.ssl.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.text.SimpleDateFormat;
import java.util.*;

public class rectravelSlice extends AbilitySlice implements Component.ClickedListener, LocationSource {
    Image back;
    Vector<Image> add;
    int index;
    CommonDialog cd,datecd,citycd;
    HashMap<Integer,Image> curpic;
    Vector<PixelMap> picseled;
    Image addpic;
    DirectionalLayout adddir;
    String mapkey="9c290cf1428115678530a1f1fb74b2c3";//appid
    DirectionalLayout father;
    Text chosedate,chosecity,finishplan,finishrec;
    String countryname = "中国";
    String city = "重庆市";
    String des = "";
    MapView mapView;
    Locator locator;
    MyLocatorCallback locatorCallback;
    AMap aMap;
    String sitkey = "6dcd28d65cfdcd5410c43cd4f7f63e09";//key
    String geourl = "https://restapi.amap.com/v3/geocode/geo?";//地址纠正接口
    String weatherdes;
    Image chosecity_pic,chosedate_pic,map_pic;
    static int issit,isweather;
    int isview;
    private LocationSource.OnLocationChangedListener mListener = null;
    public static class HttpX509TrustManager implements X509TrustManager{

        @Override
        public void checkClientTrusted(X509Certificate[] x509Certificates, String s) throws CertificateException {

        }

        @Override
        public void checkServerTrusted(X509Certificate[] x509Certificates, String s) throws CertificateException {

        }

        @Override
        public X509Certificate[] getAcceptedIssuers() {
            return null;
        }
    }
    public static String httpGet(String urlStr){
        StringBuffer sb = new StringBuffer();
        try{
            SSLContext sslcontext = SSLContext.getInstance("SSL");
            TrustManager[] tm = {new HttpX509TrustManager()};
            sslcontext.init(null,tm,new SecureRandom());
            HostnameVerifier ignoreHostnameVerifier = new HostnameVerifier() {
                @Override
                public boolean verify(String s, SSLSession sslSession) {
                    System.out.println("WARNING: Hostname is not matched for cert.");
                    return true;
                }
            };
            HttpsURLConnection.setDefaultHostnameVerifier(ignoreHostnameVerifier);
            HttpsURLConnection.setDefaultSSLSocketFactory(sslcontext.getSocketFactory());
            URL url = new URL(urlStr);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setReadTimeout(10000);
            connection.setConnectTimeout(10000);
            connection.connect();
            int code = connection.getResponseCode();
            if(code == HttpURLConnection.HTTP_OK){
                BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                String temp;
                while((temp = reader.readLine())!=null){
                    sb.append(temp);
                }
                reader.close();
            }
            connection.disconnect();
        }catch (Exception e){
            e.printStackTrace();
            return e.getMessage();
        }
        return sb.toString();
    }
    public String[] getweather(String citycode){
        String weatherurl = "https://restapi.amap.com/v3/weather/weatherInfo?";
        StringBuffer stringBuffer = new StringBuffer(weatherurl);
        stringBuffer.append("city=").append(citycode).append("&key=").append(sitkey);
        String res = httpGet(stringBuffer.toString());
        String[] reslist = new String[5];
        System.out.println("天气描述"+res);
        int index1 = res.indexOf("weather");
        int index2 = res.indexOf("temperature");
        String m1 = res.substring(index1,index2);
        index1 = m1.indexOf(":");
        index2 = m1.indexOf(",");
        m1 = m1.substring(index1+2,index2-1);
        reslist[0] = m1;

        index1 = res.indexOf("province");
        index2 = res.indexOf("city");
        String pro = res.substring(index1,index2);
        index1 =pro.indexOf(":");
        index2 = pro.indexOf(",");
        pro = pro.substring(index1+2,index2-1);
        city=pro;

        index1 = res.indexOf("temperature");
        index2 = res.indexOf("winddirection");
        String m2 = res.substring(index1,index2);
        index1 = m2.indexOf(":");
        index2 = m2.indexOf(",");
        m2 = m2.substring(index1+2,index2-1);
        reslist[1]=m2;

        index1 = res.indexOf("wind");
        index2 = res.lastIndexOf("wind");
        String m3 = res.substring(index1,index2);
        index1 = m3.indexOf(":");
        index2 = m3.indexOf(",");
        m3 = m3.substring(index1+2,index2-1);
        reslist[2]=m3;

        index1 = res.lastIndexOf("wind");
        index2 = res.indexOf("humidity");
        String m4 = res.substring(index1,index2);
        index1 = m4.indexOf(":");
        index2 = m4.indexOf(",");
        m4 = m4.substring(index1+2,index2-1);
        reslist[3]=m4;

        index1 = res.indexOf("humidity");
        index2 = res.indexOf("reporttime");
        String m5 = res.substring(index1,index2);
        index1 = m5.indexOf(":");
        index2 = m5.indexOf(",");
        m5 = m5.substring(index1+2,index2-1);
        reslist[4] =m5;

        return reslist;
    }

    private void getMyLocationStyle(){
        MyLocationStyle locationStyle = new MyLocationStyle();
        locationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_FOLLOW_NO_CENTER);
        locationStyle.interval(2000);
        locationStyle.strokeColor(Color.BLUE);
        locationStyle.radiusFillColor(Color.LTGRAY);
        aMap.setMyLocationStyle(locationStyle);

        aMap.getUiSettings().setAllGesturesEnabled(true);//当前地图支持所有手势
        aMap.getUiSettings().setMyLocationButtonEnabled(false);//显示定位按钮

//        aMap.getUiSettings().setGestureScaleByMapCenter(true);
//        aMap.getUiSettings().setScrollGesturesEnabled(true);

//        aMap.getUiSettings().setZoomGesturesEnabled(true);//双指缩放手势
        aMap.setLocationSource(this);
        aMap.setMyLocationEnabled(true);
    }

    class MyLocatorCallback implements LocatorCallback{

        @Override
        public void onLocationReport(Location location) {
            GeoConvert geoConvert = new GeoConvert();
            try{
                weatherdes="";

                List<GeoAddress> addressList = geoConvert.getAddressFromLocation(location.getLatitude(),location.getLongitude(),1);
                des = addressList.get(0).getDescriptions(0);//获取详细地理位置描述
                StringBuffer stringBuffer = new StringBuffer(geourl);
                stringBuffer.append("address=").append(des).append("&output=JSON").append("&key=").append(sitkey);
                String res = httpGet(stringBuffer.toString());

                int codeindex = res.indexOf("adcode");
                int cityindex = res.lastIndexOf("street");
                String forcode = res.substring(codeindex,cityindex);
                String rescode = "";
                for(int i=0;i<forcode.length();i++){
                    if(forcode.charAt(i)<='9'&&forcode.charAt(i)>='0')
                        rescode+=forcode.charAt(i);
                }
                String[] reslist = new String[5];
                reslist = getweather(rescode);
                weatherdes += "天气: "+reslist[0]+" | 温度: "+reslist[1]+" | 风向: "+reslist[2]+" | 风力: "+reslist[3]+" | 湿度: "+reslist[4];
                System.out.println("weatherdes: "+weatherdes);
                int index = res.indexOf("location");
                res = res.substring(index);
                index = res.indexOf(":");
                int index2 = res.lastIndexOf(",");
                res = res.substring(index+1,index2);
                res = res.substring(1,res.length()-1);
                index = res.indexOf(",");
                double reallat = Double.parseDouble(res.substring(0,index));
                double reallog = Double.parseDouble(res.substring(index+1));
                LatLng latLng = new LatLng(reallog,reallat);
                Location location1 = location;
                location1.setLatitude(reallog);
                location1.setLongitude(reallat);
                getMyLocationStyle();
                mListener.onLocationChanged(location1);
                aMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng,16));
            } catch (IOException e){
                throw new RuntimeException(e);
            }
        }


        @Override
        public void onStatusChanged(int i) {

        }

        @Override
        public void onErrorReport(int i) {

        }
    }
    Text map;
    RequestParam requestParam;
    RdbStore store;

    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_rectravel);
        store = MainAbilitySlice.store;
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

        addpic = findComponentById(ResourceTable.Id_addpic);
        adddir = findComponentById(ResourceTable.Id_addpicdir);
        curpic = new HashMap<Integer, Image>();
        picseled = new Vector<PixelMap>();
        add = new Vector<Image>();
        requestPermissionsFromUser(new String[]{"ohos.permission.READ_USER_STORAGE","ohos.permission.CAMERA"},RequestCode);
        String[] permission = {"ohos.permission.READ_USER_STORAGE","ohos.permission.WRITE_USER_STORAGE","ohos.permission.Location",};
        requestPermissionsFromUser(permission,0);
        addpic.setClickedListener(this);
        addpic.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        addpic.setScaleX(0.8f);
                        addpic.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        addpic.setScaleX(1.0f);
                        addpic.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        addpic.setScaleX(1.0f);
                        addpic.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });
        addpic.setCornerRadius(25);
        add.add(addpic);
        picseled.add(addpic.getPixelMap());
        curpic.put(add.indexOf(addpic),addpic);

        father = findComponentById(ResourceTable.Id_father);
        try {
            Resource resource = getResourceManager().getResource(ResourceTable.Media_rec_bk);//这里需要
            PixelMapElement pixelMapElement = new PixelMapElement(resource);
            father.setBackground(pixelMapElement);
        } catch (IOException e) {
            throw new RuntimeException(e);
        } catch (NotExistException e) {
            throw new RuntimeException(e);
        }
        SimpleDateFormat sdf = new SimpleDateFormat();
        sdf.applyPattern("yyyy-MM-dd HH:mm:ss a");//a为am/pm标记
        Date date = new Date();
//        System.out.println("现在时间: " + sdf.format(date));
        int day = Integer.parseInt(String.valueOf(sdf.format(date).substring(8,10)));
        int month = Integer.parseInt(String.valueOf(sdf.format(date).substring(5,7)));
        int year = Integer.parseInt(String.valueOf(sdf.format(date).substring(0,4)));
        chosedate = findComponentById(ResourceTable.Id_chosedate);
        String curdate = String.valueOf(year)+"-"+String.valueOf(month)+"-"+String.valueOf(day);
        chosedate.setText(curdate);
        chosedate_pic = findComponentById(ResourceTable.Id_chosedate_pic);
        chosedate_pic.setClickedListener(this);
        chosedate_pic.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        chosedate_pic.setScaleX(0.8f);
                        chosedate_pic.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        chosedate_pic.setScaleX(1.0f);
                        chosedate_pic.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        chosedate_pic.setScaleX(1.0f);
                        chosedate_pic.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });
//        chosedate.setClickedListener(this);
//        chosedate.setTouchEventListener(new Component.TouchEventListener() {
//            @Override
//            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
//                switch (touchEvent.getAction()) {
//                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
//                        chosedate.setScaleX(0.8f);
//                        chosedate.setScaleY(0.8f);
//                        break;
//                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
//                        chosedate.setScaleX(1.0f);
//                        chosedate.setScaleY(1.0f);
//                        break;
//                    case TouchEvent.CANCEL: //手指取消时
//                        chosedate.setScaleX(1.0f);
//                        chosedate.setScaleY(1.0f);
//                        break;
//                    default:
//                        break;
//                }
//                return true;
//            }
//        });

        locator = new Locator(this);
        locatorCallback = new MyLocatorCallback();
        map = (Text)findComponentById(ResourceTable.Id_map);
        map_pic = findComponentById(ResourceTable.Id_map_pic);
        map_pic.setClickedListener(this);
        map_pic.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        map_pic.setScaleX(0.8f);
                        map_pic.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        map_pic.setScaleX(1.0f);
                        map_pic.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        map_pic.setScaleX(1.0f);
                        map_pic.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });
//        map.setClickedListener(this);
//        map.setTouchEventListener(new Component.TouchEventListener() {
//            @Override
//            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
//                switch (touchEvent.getAction()) {
//                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
//                        map.setScaleX(0.8f);
//                        map.setScaleY(0.8f);
//                        break;
//                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
//                        map.setScaleX(1.0f);
//                        map.setScaleY(1.0f);
//                        break;
//                    case TouchEvent.CANCEL: //手指取消时
//                        map.setScaleX(1.0f);
//                        map.setScaleY(1.0f);
//                        break;
//                    default:
//                        break;
//                }
//                return true;
//            }
//        });
        map.setTruncationMode(Text.TruncationMode.ELLIPSIS_AT_END);
        requestParam = new RequestParam(RequestParam.SCENE_NAVIGATION);

        finishplan = findComponentById(ResourceTable.Id_finishplan);
        finishplan.setClickedListener(this);
        finishplan.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        finishplan.setScaleX(0.8f);
                        finishplan.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        finishplan.setScaleX(1.0f);
                        finishplan.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        finishplan.setScaleX(1.0f);
                        finishplan.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });

        finishrec = findComponentById(ResourceTable.Id_finishrec);
        finishrec.setClickedListener(this);
        finishrec.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        finishrec.setScaleX(0.8f);
                        finishrec.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        finishrec.setScaleX(1.0f);
                        finishrec.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        finishrec.setScaleX(1.0f);
                        finishrec.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });

        chosecity_pic = findComponentById(ResourceTable.Id_chosecity_pic);
        chosecity_pic.setClickedListener(this);
        chosecity_pic.setTouchEventListener(new Component.TouchEventListener() {
            @Override
            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                switch (touchEvent.getAction()) {
                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                        chosecity_pic.setScaleX(0.8f);
                        chosecity_pic.setScaleY(0.8f);
                        break;
                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                        chosecity_pic.setScaleX(1.0f);
                        chosecity_pic.setScaleY(1.0f);
                        break;
                    case TouchEvent.CANCEL: //手指取消时
                        chosecity_pic.setScaleX(1.0f);
                        chosecity_pic.setScaleY(1.0f);
                        break;
                    default:
                        break;
                }
                return true;
            }
        });

        chosecity = findComponentById(ResourceTable.Id_chosecity);
//        chosecity.setClickedListener(this);
//        chosecity.setTouchEventListener(new Component.TouchEventListener() {
//            @Override
//            public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
//                switch (touchEvent.getAction()) {
//                    case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
//                        chosecity.setScaleX(0.8f);
//                        chosecity.setScaleY(0.8f);
//                        break;
//                    case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
//                        chosecity.setScaleX(1.0f);
//                        chosecity.setScaleY(1.0f);
//                        break;
//                    case TouchEvent.CANCEL: //手指取消时
//                        chosecity.setScaleX(1.0f);
//                        chosecity.setScaleY(1.0f);
//                        break;
//                    default:
//                        break;
//                }
//                return true;
//            }
//        });


    }

    public byte[] pixtobyte(PixelMap pixelMap){
        ImagePacker imagePacker = ImagePacker.create();
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        ImagePacker.PackingOptions packingOptions = new ImagePacker.PackingOptions();packingOptions.quality = 80;
        imagePacker.initializePacking(byteArrayOutputStream,packingOptions);
        imagePacker.addImage(pixelMap);
        imagePacker.finalizePacking();
        byte[] bytes = byteArrayOutputStream.toByteArray();
        return bytes;
    }

    Uri imageUri1;
    private void take_photo(){
        ValuesBucket valuesBucket = new ValuesBucket();
        valuesBucket.putString("relative_path","DCIM/Camera/");
        valuesBucket.putString(AVStorage.Images.Media.MIME_TYPE,"image/JPEG");
        DataAbilityHelper helper = DataAbilityHelper.creator(getContext());
        try{
            int id = helper.insert(AVStorage.Images.Media.EXTERNAL_DATA_ABILITY_URI,valuesBucket);
            imageUri1 = Uri.appendEncodedPathToUri(AVStorage.Images.Media.EXTERNAL_DATA_ABILITY_URI,String.valueOf(id));
            Intent intent = new Intent();
            Operation operation = new Intent.OperationBuilder()
                    .withAction("android.media.action.IMAGE_CAPTURE")
                    .build();
            intent.setOperation(operation);
            intent.setParam(AVStorage.Images.Media.OUTPUT,imageUri1);
            startAbilityForResult(intent,1);
        }catch (DataAbilityRemoteException e){
            e.printStackTrace();
        }
    }
    int RequestCode = 1123;
    private void select_pic(){
        Intent intent = new Intent();
        Operation opt = new Intent.OperationBuilder().withAction("android.intent.action.GET_CONTENT").build();
        intent.setOperation(opt);
        intent.addFlags(Intent.FLAG_NOT_OHOS_COMPONENT);
        intent.setType("image/*");
        startAbilityForResult(intent,RequestCode);
    }

    protected void onAbilityResult(int requestCode, int resultCode, Intent resultData) {
        if (requestCode == RequestCode) {//相册调用
            String ImgUri = null;
            try {
                ImgUri = resultData.getUriString();
            } catch (Exception e) {
                return;
            }

            DataAbilityHelper helper = DataAbilityHelper.creator(getContext());
            ImageSource ims = null;
            String ImgId = null;
            if (ImgUri.lastIndexOf("%3A") != -1) {
                ImgId = ImgUri.substring(ImgUri.lastIndexOf("%3A") + 3);

            } else {
                ImgId = ImgUri.substring(ImgUri.lastIndexOf('/') + 1);
            }

            Uri uri = Uri.appendEncodedPathToUri(AVStorage.Images.Media.EXTERNAL_DATA_ABILITY_URI,String.valueOf(ImgId));

            try{
                FileDescriptor fd = helper.openFile(uri,"r");
                ims = ImageSource.create(fd,null);
                PixelMap px = ims.createPixelmap(null);
                curpic.get(index).setPixelMap(px);
                picseled.set(index,px);
                if(index==picseled.size()-1){
                    Image image = new Image(this);
                    image.setPixelMap(ResourceTable.Media_add_pic);//这里需要
                    image.setScaleMode(Image.ScaleMode.STRETCH);
                    image.setWidth(addpic.getWidth());
                    image.setHeight(addpic.getHeight());
                    image.setClickedListener(this);
                    image.setCornerRadius(25);
                    image.setMarginLeft(10);
                    add.add(image);
                    curpic.put(add.indexOf(image),image);
                    adddir.addComponent(image);
                    picseled.add(image.getPixelMap());
                }
            } catch (DataAbilityRemoteException | FileNotFoundException e) {
                throw new RuntimeException(e);
            }finally {
                if(ims !=null){
                    ims.release();
                }
            }

        }
        else if(requestCode == 1){//相机调用
            DataAbilityHelper helper = DataAbilityHelper.creator(getContext());
            Uri uri = imageUri1;
            try{
                FileDescriptor fd = helper.openFile(uri,"r");
                ImageSource ims = ImageSource.create(fd,null);
                PixelMap px = ims.createPixelmap(null);
                curpic.get(index).setPixelMap(px);
                picseled.set(index,px);
                if(index==picseled.size()-1){
                    Image image = new Image(this);
                    image.setPixelMap(ResourceTable.Media_add_pic);//这里需要
                    image.setScaleMode(Image.ScaleMode.STRETCH);
                    image.setWidth(addpic.getWidth());
                    image.setHeight(addpic.getHeight());
                    image.setClickedListener(this);
                    image.setCornerRadius(25);
                    image.setMarginLeft(10);
                    add.add(image);
                    curpic.put(add.indexOf(image),image);
                    adddir.addComponent(image);
                    picseled.add(image.getPixelMap());
                }
            } catch (DataAbilityRemoteException | FileNotFoundException e) {
                throw new RuntimeException(e);
            }
        }
    }


    @Override
    public void activate(LocationSource.OnLocationChangedListener onLocationChangedListener){mListener = onLocationChangedListener;}
    @Override
    public void deactivate() {
        mListener =null;
    }

    void ini(){
        super.setUIContent(ResourceTable.Layout_rectravel);
        try{
            Resource resource = getResourceManager().getResource(ResourceTable.Media_rec_bk);//这里需要
            PixelMapElement pixelMapElement = new PixelMapElement(resource);
            father.setBackground(pixelMapElement);
        }catch (IOException e){
            e.printStackTrace();
        } catch (NotExistException e){
            e.printStackTrace();
        }
    }

    String btcity="";

    @Override
    public void onClick(Component component) {
        if(component.getId()==ResourceTable.Id_back){
            Intent i = new Intent();
            Operation operation = new Intent.OperationBuilder()
                    .withDeviceId("")
                    .withBundleName("com.example.myapplication")
                    .withAbilityName("com.example.myapplication.MainAbility")
                    .build();
            i.setOperation(operation);
            startAbility(i);
        }
        else if(add.contains(component)){
            index = add.indexOf(component);
            int pm_px = AttrHelper.vp2px(getContext().getResourceManager().getDeviceCapability().width,this);
            DirectionalLayout directionalLayout = new DirectionalLayout(this);
            directionalLayout.setOrientation(Component.VERTICAL);
            directionalLayout.setWidth(pm_px);
            directionalLayout.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            try {
                Resource resource = getResourceManager().getResource(ResourceTable.Media_bk_end);//这里需要
                PixelMapElement pixelMapElement = new PixelMapElement(resource);
                directionalLayout.setBackground(pixelMapElement);
            } catch (IOException e) {
                throw new RuntimeException(e);
            } catch (NotExistException e) {
                throw new RuntimeException(e);
            }
            int len = pm_px-200;
            DirectionalLayout directionalLayout1 = new DirectionalLayout(this);
            directionalLayout1.setOrientation(Component.HORIZONTAL);
            directionalLayout1.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            directionalLayout1.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            Image image1 = new Image(this);
            image1.setWidth(150);
            image1.setHeight(150);
            try{
                Resource resource = getResourceManager().getResource(ResourceTable.Media_xiangji);//这里需要Media_recbk
                PixelMapElement pixelMapElement = new PixelMapElement(resource);
                image1.setBackground(pixelMapElement);
            } catch (IOException e){
                e.printStackTrace();
            } catch (NotExistException e){
                e.printStackTrace();
            }
            image1.setMarginLeft(len/2-50);
            image1.setMarginTop(10);

            DirectionalLayout directionalLayout2 = new DirectionalLayout(this);
            directionalLayout2.setOrientation(Component.HORIZONTAL);
            directionalLayout2.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            directionalLayout2.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            Image image2 = new Image(this);
            image2.setWidth(150);
            image2.setHeight(150);
            try{
                Resource resource = getResourceManager().getResource(ResourceTable.Media_xiangce);//这里需要Media_recbk
                PixelMapElement pixelMapElement = new PixelMapElement(resource);
                image2.setBackground(pixelMapElement);
            } catch (IOException e){
                e.printStackTrace();
            } catch (NotExistException e){
                e.printStackTrace();
            }
            image2.setMarginLeft(len/2-50);
            image2.setMarginTop(10);

            DirectionalLayout directionalLayout3 = new DirectionalLayout(this);
            directionalLayout3.setOrientation(Component.HORIZONTAL);
            directionalLayout3.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            directionalLayout3.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            Image image3 = new Image(this);
            image3.setWidth(150);
            image3.setHeight(150);
            try{
                Resource resource = getResourceManager().getResource(ResourceTable.Media_shanchu);//这里需要Media_recbk
                PixelMapElement pixelMapElement = new PixelMapElement(resource);
                image3.setBackground(pixelMapElement);
            } catch (IOException e){
                e.printStackTrace();
            } catch (NotExistException e){
                e.printStackTrace();
            }
            image3.setMarginLeft(len/2-50);
            image3.setMarginTop(10);

            DirectionalLayout directionalLayout4 = new DirectionalLayout(this);
            directionalLayout4.setOrientation(Component.HORIZONTAL);
            directionalLayout4.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            directionalLayout4.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            Image image4 = new Image(this);
            image4.setWidth(150);
            image4.setHeight(150);
            try{
                Resource resource = getResourceManager().getResource(ResourceTable.Media_tuichu);//这里需要Media_recbk
                PixelMapElement pixelMapElement = new PixelMapElement(resource);
                image4.setBackground(pixelMapElement);
            } catch (IOException e){
                e.printStackTrace();
            } catch (NotExistException e){
                e.printStackTrace();
            }
            image4.setMarginLeft(len/2-50);
            image4.setMarginTop(10);
            Text camera = new Text(this);
            Text album = new Text(this);
            Text cancel = new Text(this);
            Text delete = new Text(this);

            camera.setWidth(pm_px);
            camera.setHeight(100);
            camera.setText("相机");
            camera.setTextSize(100);
            camera.setMarginLeft(10);
//            camera.setMarginLeft(len/2);
            camera.setMarginTop(25);
            directionalLayout1.addComponent(image1);
            directionalLayout1.addComponent(camera);


            album.setWidth(pm_px);
            album.setHeight(100);
            album.setText("图库");
            album.setTextSize(100);
            album.setMarginLeft(10);
//            album.setMarginLeft(len/2);
            album.setMarginTop(25);
            directionalLayout2.addComponent(image2);
            directionalLayout2.addComponent(album);

            delete.setWidth(pm_px);
            delete.setHeight(100);
            delete.setText("删除");
            delete.setTextSize(100);
            delete.setMarginLeft(10);
//            delete.setMarginLeft(len/2);
            delete.setMarginTop(25);
            directionalLayout3.addComponent(image3);
            directionalLayout3.addComponent(delete);

            cancel.setWidth(pm_px);
            cancel.setHeight(100);
            cancel.setText("取消");
            cancel.setTextSize(100);
            cancel.setMarginLeft(10);
//            cancel.setMarginLeft(len/2);
            cancel.setMarginTop(50);
            cancel.setMarginTop(25);
            directionalLayout4.addComponent(image4);
            directionalLayout4.addComponent(cancel);



            image1.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    take_photo();
                    cd.destroy();
                }
            });
            image1.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            image1.setScaleX(0.8f);
                            image1.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            image1.setScaleX(1.0f);
                            image1.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            image1.setScaleX(1.0f);
                            image1.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            image2.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    select_pic();
                    cd.destroy();
                }
            });
            image2.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            image2.setScaleX(0.8f);
                            image2.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            image2.setScaleX(1.0f);
                            image2.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            image2.setScaleX(1.0f);
                            image2.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            image4.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    cd.destroy();
                }
            });
            image4.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            image3.setScaleX(0.8f);
                            image3.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            image3.setScaleX(1.0f);
                            image3.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            image3.setScaleX(1.0f);
                            image3.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            image3.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    adddir.removeComponent(add.get(index));
                    picseled.remove(add.get(index).getPixelMap());
                    add.remove(index);
                    curpic.clear();
                    for(int i=0;i<add.size();i++)
                        curpic.put(i,add.get(i));
                    if(picseled.size()==0){
                        add.clear();
                        curpic.clear();
                        addpic.setPixelMap(ResourceTable.Media_add_pic);
                        add.add(addpic);
                        adddir.removeAllComponents();
                        curpic.put(add.indexOf(index),addpic);
                        adddir.addComponent(addpic);
                        picseled.add(addpic.getPixelMap());
                    }
                    cd.destroy();
                }
            });
            image3.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            image4.setScaleX(0.8f);
                            image4.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            image4.setScaleX(1.0f);
                            image4.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            image4.setScaleX(1.0f);
                            image4.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            directionalLayout.addComponent(directionalLayout1);
            directionalLayout.addComponent(directionalLayout2);
            directionalLayout.addComponent(directionalLayout3);
            directionalLayout.addComponent(directionalLayout4);
            directionalLayout.setHeight(700);

            cd = new CommonDialog(this.getContext());
            cd.setAlignment(LayoutAlignment.BOTTOM);
            cd.setCornerRadius(30);
            cd.setContentCustomComponent(directionalLayout);
            cd.show();
        }
        else if(component==map_pic){
            issit=0;isweather=0;isview=0;//用户可能多次点击定位，每次定位操作时，先初始化
            String[] permission = {"ohos.permission.LOCATION"};
            requestPermissionsFromUser(permission,0);

            mapView = new MapView(this);
            aMap = mapView.getMap();
            mapView.onCreate(null);
            mapView.onResume();

            ComponentContainer.LayoutConfig layoutConfig = new ComponentContainer.LayoutConfig(
                    ComponentContainer.LayoutConfig.MATCH_PARENT,ComponentContainer.LayoutConfig.MATCH_PARENT
            );
            mapView.setLayoutConfig(layoutConfig);
            aMap.getUiSettings().setZoomControlsEnabled(false);//显示缩放按钮

            Image back = new Image(this);
            back.setPixelMap(ResourceTable.Media_back);
            back.setScaleMode(Image.ScaleMode.STRETCH);
            back.setWidth(150);
            back.setHeight(150);

            Image weather = new Image(this);
            weather.setHeight(150);
            weather.setWidth(150);
            weather.setScaleMode(Image.ScaleMode.STRETCH);
            weather.setPixelMap(ResourceTable.Media_weather);//这里需要 Media_weather
            weather.setMarginTop(800);

            Image sit = new Image(this);
            sit.setMarginTop(950);
            sit.setPixelMap(ResourceTable.Media_sit);//这里需要Media_sit
            sit.setHeight(150);
            sit.setWidth(150);
            sit.setScaleMode(Image.ScaleMode.STRETCH);

            Image view = new Image(this);
            view.setMarginTop(150);
            view.setPixelMap(ResourceTable.Media_view);//这里需要Media_view
            view.setHeight(100);
            view.setWidth(150);
            view.setScaleMode(Image.ScaleMode.STRETCH);

            Image button_large = new Image(this);
            button_large.setHeight(150);
            button_large.setWidth(150);
            button_large.setScaleMode(Image.ScaleMode.STRETCH);
            button_large.setPixelMap(ResourceTable.Media_fangda);
            button_large.setMarginTop(800);
            button_large.setMarginLeft(1070);

            Image button_small = new Image(this);
            button_small.setHeight(150);
            button_small.setWidth(150);
            button_small.setScaleMode(Image.ScaleMode.STRETCH);
            button_small.setPixelMap(ResourceTable.Media_suoxiao);
            button_small.setMarginTop(950);
            button_small.setMarginLeft(1070);

            Image down = new Image(this);
            down.setHeight(150);
            down.setWidth(150);
            down.setScaleMode(Image.ScaleMode.STRETCH);
            down.setPixelMap(ResourceTable.Media_down);
            down.setMarginTop(2050);
            down.setMarginLeft(550);

            Image up = new Image(this);
            up.setHeight(150);
            up.setWidth(150);
            up.setScaleMode(Image.ScaleMode.STRETCH);
            up.setPixelMap(ResourceTable.Media_up);
            up.setMarginTop(1850);
            up.setMarginLeft(550);

            Image left = new Image(this);
            left.setHeight(150);
            left.setWidth(150);
            left.setScaleMode(Image.ScaleMode.STRETCH);
            left.setPixelMap(ResourceTable.Media_left);
            left.setMarginTop(1950);
            left.setMarginLeft(450);

            Image right = new Image(this);
            right.setHeight(150);
            right.setWidth(150);
            right.setScaleMode(Image.ScaleMode.STRETCH);
            right.setPixelMap(ResourceTable.Media_right);
            right.setMarginTop(1950);
            right.setMarginLeft(650);

            mapView.addComponent(back);
            mapView.addComponent(weather);
            mapView.addComponent(sit);
            mapView.addComponent(view);
            mapView.addComponent(button_large);
            mapView.addComponent(button_small);
            mapView.addComponent(down);
            mapView.addComponent(up);
            mapView.addComponent(left);
            mapView.addComponent(right);

            super.setUIContent(mapView);
            locator.startLocating(requestParam,locatorCallback);


            back.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    locator.stopLocating(locatorCallback);
                    ini();
                    if(issit==1){
                        map.setText(des);
                    }else{
                        map.setText("未选择");
                    }
                    isview=0;
                }
            });
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
            weather.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    if(isweather==0){
                        isweather=1;
                        weather.setPixelMap(ResourceTable.Media_weathered);//这里需要Media_weathered
                    }else{
                        isweather=0;
                        weather.setPixelMap(ResourceTable.Media_weather);//这里需要Media_weather
                    }
                }
            });
            weather.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            weather.setScaleX(0.8f);
                            weather.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            weather.setScaleX(1.0f);
                            weather.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            weather.setScaleX(1.0f);
                            weather.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            sit.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    if(issit==0){
                        issit=1;
                        sit.setPixelMap(ResourceTable.Media_sited);//这里需要Media_sited
                    }else{
                        issit=0;
                        sit.setPixelMap(ResourceTable.Media_sit);//这里需要Media_dit
                    }
                }
            });
            sit.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            sit.setScaleX(0.8f);
                            sit.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            sit.setScaleX(1.0f);
                            sit.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            sit.setScaleX(1.0f);
                            sit.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            view.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    if(isview==0){
                        isview=1;
                        view.setPixelMap(ResourceTable.Media_viewed);//这里需要Media_viewed
                        locator.stopLocating(locatorCallback);
                    }else{
                        isview=0;
                        view.setPixelMap(ResourceTable.Media_view);//这里需要Media_view
                        locator.startLocating(requestParam,locatorCallback);
                    }
                }
            });
            view.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            view.setScaleX(0.8f);
                            view.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            view.setScaleX(1.0f);
                            view.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            view.setScaleX(1.0f);
                            view.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            button_large.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    aMap.animateCamera(CameraUpdateFactory.zoomIn());
                }
            });
            button_small.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    aMap.animateCamera(CameraUpdateFactory.zoomOut());
                }
            });
            up.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    aMap.animateCamera(CameraUpdateFactory.scrollBy(0,-100));
                }
            });
            down.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    aMap.animateCamera(CameraUpdateFactory.scrollBy(0,100));
                }
            });
            left.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    aMap.animateCamera(CameraUpdateFactory.scrollBy(-100,0));
                }
            });
            right.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    aMap.animateCamera(CameraUpdateFactory.scrollBy(100,0));
                }
            });
            button_large.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            button_large.setScaleX(0.8f);
                            button_large.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            button_large.setScaleX(1.0f);
                            button_large.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            button_large.setScaleX(1.0f);
                            button_large.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            button_small.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            button_small.setScaleX(0.8f);
                            button_small.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            button_small.setScaleX(1.0f);
                            button_small.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            button_small.setScaleX(1.0f);
                            button_small.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            down.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            down.setScaleX(0.8f);
                            down.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            down.setScaleX(1.0f);
                            down.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            down.setScaleX(1.0f);
                            down.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            up.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            up.setScaleX(0.8f);
                            up.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            up.setScaleX(1.0f);
                            up.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            up.setScaleX(1.0f);
                            up.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            left.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    aMap.animateCamera(CameraUpdateFactory.scrollBy(-100,0));
                }
            });
            left.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            left.setScaleX(0.8f);
                            left.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            left.setScaleX(1.0f);
                            left.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            left.setScaleX(1.0f);
                            left.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
            right.setClickedListener(new Component.ClickedListener() {
                @Override
                public void onClick(Component component) {
                    aMap.animateCamera(CameraUpdateFactory.scrollBy(100,0));
                }
            });
            right.setTouchEventListener(new Component.TouchEventListener() {
                @Override
                public boolean onTouchEvent(Component component, TouchEvent touchEvent) {
                    switch (touchEvent.getAction()) {
                        case TouchEvent.PRIMARY_POINT_DOWN: //手指按下时
                            right.setScaleX(0.8f);
                            right.setScaleY(0.8f);
                            break;
                        case TouchEvent.PRIMARY_POINT_UP: //手指抬起时
                            right.setScaleX(1.0f);
                            right.setScaleY(1.0f);
                            break;
                        case TouchEvent.CANCEL: //手指取消时
                            right.setScaleX(1.0f);
                            right.setScaleY(1.0f);
                            break;
                        default:
                            break;
                    }
                    return true;
                }
            });
        }
        else if(component==chosedate_pic){
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
                String curdate = year+"-"+month+"-"+day;
                chosedate.setText(curdate);
                datecd.destroy();
            }
        });
        }
        else if(component==chosecity_pic){
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
            String[] citylist = new String[]{"城市","北京","天津","河北","内蒙古","上海","重庆","黑龙江","吉林","辽宁","新疆","甘肃",
                     "青海","陕西","宁夏","河南","山东","山西","安徽","湖北","湖南","江苏","四川","贵州","云南","广西","西藏","浙江","江西","广东","福建","台湾","海南","香港","澳门"};
            citypicker.setDisplayedData(citylist);
            citypicker.setValueChangedListener(new Picker.ValueChangedListener() {
                @Override
                public void onValueChanged(Picker picker, int i, int i1) {
                    btcity = citylist[i1];
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
                    chosecity.setText(btcity);
                    System.out.println(btcity);
                    citycd.destroy();
                }
            });
        }
        else if(component==finishplan){
            Random random = new Random();
            String id="";
            int curid = 0;
            do{
                id="";
                for(int i=1;i<=6;i++){
                    id+=String.valueOf(random.nextInt(10));
                }
                curid = Integer.parseInt(id);
                String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
                RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",curid);
                ResultSet resultSet = store.query(rdbPredicates,columns);
                if(resultSet.getRowCount()==0){
                    break;
                }
            }while(true);
            ValuesBucket valuesBucket = new ValuesBucket();
            valuesBucket.putInteger("id",curid);
            valuesBucket.putInteger("type",0);
            String picdes="";
            Vector<byte[]>bytevec = new Vector<byte[]>();
            int totallen=0;
            for(int i=0;i<picseled.size()-1;i++){
                byte[] curbytes;
                curbytes = pixtobyte(picseled.get(i));
                bytevec.add(curbytes);
                totallen+=curbytes.length;
                picdes+=String.valueOf(curbytes.length)+",";
            }
            byte[] allpicbyte = new byte[totallen];
            int curindex=0;
            for(int i=0;i<bytevec.size();i++){
                int curlen = bytevec.get(i).length;
                byte[] curbytes = bytevec.get(i);
                for(int j=curindex;j<curindex+curlen;j++){
                    allpicbyte[j] = curbytes[j-curindex];
                }
                curindex+=curlen;
            }
            valuesBucket.putString("picdes",picdes);
            String sdes="";
            if(issit==0) {
                sdes = "未选择";
            }
            else{
                issit=0;
                sdes = des;
            }
            String mdes="";
            if(isweather==0){
                mdes="未选择";
            }else{
                isweather=0;
                mdes=weatherdes;
            }
            if(!btcity.equals("定位")){
                city = btcity;
//                sdes=city;
            }
            TextField beizhu = findComponentById(ResourceTable.Id_des);
            TextField biaoti = findComponentById(ResourceTable.Id_title);
            valuesBucket.putString("sitdes",sdes);
            valuesBucket.putString("weather",mdes);
            valuesBucket.putString("date",chosedate.getText());
            valuesBucket.putString("title",biaoti.getText());
            valuesBucket.putString("des",beizhu.getText());
            valuesBucket.putByteArray("picbyte",allpicbyte);
            valuesBucket.putString("city",city);
            valuesBucket.putInteger("like",0);

            store.insert("test",valuesBucket);
            System.out.println("插入的计划记录");
            System.out.println(valuesBucket);
            ToastDialog toastDialog = new ToastDialog(this);
            toastDialog.setText("创建成功");
            toastDialog.show();
            System.out.println("picdes: "+picdes);
            System.out.println("piclen: "+String.valueOf(allpicbyte.length));
            Intent i = new Intent();
            Operation operation = new Intent.OperationBuilder()
                    .withDeviceId("")
                    .withBundleName("com.example.myapplication")
                    .withAbilityName("com.example.myapplication.MainAbility")
                    .build();
            i.setOperation(operation);
            startAbility(i);
        }
        else if(component==finishrec){
            Random random = new Random();
            String id="";
            int curid = 0;
            do{
                id="";
                for(int i=1;i<=6;i++){
                    id+=String.valueOf(random.nextInt(10));
                }
                curid = Integer.parseInt(id);
                String[] columns = new String[] {"id","type","picdes","sitdes","weather","date","title","des","picbyte","city","like"};
                RdbPredicates rdbPredicates = new RdbPredicates("test").equalTo("id",curid);
                ResultSet resultSet = store.query(rdbPredicates,columns);
                if(resultSet.getRowCount()==0){
                    break;
                }
            }while(true);
            ValuesBucket valuesBucket = new ValuesBucket();
            valuesBucket.putInteger("id",curid);
            valuesBucket.putInteger("type",1);
            String picdes="";
            Vector<byte[]>bytevec = new Vector<byte[]>();
            int totallen=0;
            for(int i=0;i<picseled.size()-1;i++){
                byte[] curbytes;
                curbytes = pixtobyte(picseled.get(i));
                bytevec.add(curbytes);
                totallen+=curbytes.length;
                picdes+=String.valueOf(curbytes.length)+",";
            }
            byte[] allpicbyte = new byte[totallen];
            int curindex=0;
            for(int i=0;i<bytevec.size();i++){
                int curlen = bytevec.get(i).length;
                byte[] curbytes = bytevec.get(i);
                for(int j=curindex;j<curindex+curlen;j++){
                    allpicbyte[j] = curbytes[j-curindex];
                }
                curindex+=curlen;
            }
            valuesBucket.putString("picdes",picdes);
            String sdes="";
            if(issit==0) {
                sdes = "未选择";
            }
            else{
                issit=0;
                sdes = des;
            }
            String mdes="";
            if(isweather==0){
                mdes="未选择";
            }else{
                isweather=0;
                mdes=weatherdes;
            }
            if(!btcity.equals("定位")){
                city = btcity;
//                sdes=city;
            }
            TextField beizhu = findComponentById(ResourceTable.Id_des);
            TextField biaoti = findComponentById(ResourceTable.Id_title);
            valuesBucket.putString("sitdes",sdes);
            valuesBucket.putString("weather",mdes);
            valuesBucket.putString("date",chosedate.getText());
            valuesBucket.putString("title",biaoti.getText());
            valuesBucket.putString("des",beizhu.getText());
            valuesBucket.putByteArray("picbyte",allpicbyte);
            valuesBucket.putString("city",city);
            valuesBucket.putInteger("like",0);

            store.insert("test",valuesBucket);
            ToastDialog toastDialog = new ToastDialog(this);
            toastDialog.setText("创建成功");
            toastDialog.show();
            System.out.println("picdes: "+picdes);
            System.out.println("piclen: "+String.valueOf(allpicbyte.length));
            Intent i = new Intent();
            Operation operation = new Intent.OperationBuilder()
                    .withDeviceId("")
                    .withBundleName("com.example.myapplication")
                    .withAbilityName("com.example.myapplication.MainAbility")
                    .build();
            i.setOperation(operation);
            startAbility(i);

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
