package com.example.myapplication.slice;

import com.example.myapplication.ImageListProvider;
import com.example.myapplication.ResourceTable;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.ability.DataAbilityHelper;
import ohos.aafwk.ability.DataAbilityRemoteException;
import ohos.aafwk.content.Intent;
import ohos.aafwk.content.Operation;
import ohos.agp.components.*;
import ohos.agp.components.element.PixelMapElement;
import ohos.agp.utils.LayoutAlignment;
import ohos.agp.window.dialog.CommonDialog;
import ohos.agp.window.dialog.ToastDialog;
import ohos.data.rdb.ValuesBucket;
import ohos.global.resource.*;
import ohos.media.image.ImageSource;
import ohos.media.image.PixelMap;
import ohos.media.photokit.metadata.AVStorage;
import ohos.utils.net.Uri;

import java.io.FileDescriptor;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class game1Slice extends AbilitySlice implements Component.ClickedListener {
    Image cur;
    Integer cur_src,back_src;
    Integer row_n=-1, col_m=-1;
    private final int RequestCode = 0;
    Uri imageUri1;
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
        super.setUIContent(ResourceTable.Layout_ability_game1);

        cur = (Image) findComponentById(ResourceTable.Id_current);
        //获取图片列表lcImageList与边框列表lcImageList_1
        ListContainer lcImgList = (ListContainer) findComponentById(ResourceTable.Id_listContainer);
        ListContainer lcImgList_1 = (ListContainer) findComponentById(ResourceTable.Id_listContainer_1);
        List<Integer> imgList = getImageList();
        List<Integer> imgList_1 = getImageList_1();
        ImageListProvider provider = new ImageListProvider(imgList, this);
        ImageListProvider provider_1 = new ImageListProvider(imgList_1, this);
        //为图片列表中的每个图片设置点击事件监听器
        provider.setListener(pos -> {
            cur.setPixelMap(imgList.get(pos));
            cur_src = imgList.get(pos);
        });
        //为边框列表中的每个图片设置点击事件监听器
        provider_1.setListener(pos -> {
            back_src = imgList_1.get(pos);
            ResourceManager rm = getResourceManager();
            Resource res = null;
            try {
                res = rm.getResource(imgList_1.get(pos));
                PixelMapElement pixelMapElement = new PixelMapElement(res);
                cur.setBackground(pixelMapElement);
            } catch (IOException e) {
                throw new RuntimeException(e);
            } catch (NotExistException e) {
                throw new RuntimeException(e);
            }
        });
        lcImgList.setItemProvider(provider);
        lcImgList_1.setItemProvider(provider_1);
        //设置开始游戏按钮、划分选择按钮、从相册获取图片按钮与拍照获取图片按钮的点击事件监听器
        Button begin = findComponentById(ResourceTable.Id_begin);
        begin.setClickedListener(this);
        Button select = findComponentById(ResourceTable.Id_select);
        select.setClickedListener(this);
        Button photo_album = (Button) findComponentById(ResourceTable.Id_xiangce);
        photo_album.setClickedListener(this);
        Button takePhoto = (Button) findComponentById(ResourceTable.Id_paizhao);
        takePhoto.setClickedListener(this);
        requestPermissionsFromUser(new String[]{"ohos.permission.READ_USER_STORAGE", "ohos.permission.CAMERA"}, RequestCode);
    }

    @Override
    public void onActive() {
        super.onActive();
    }

    @Override
    public void onForeground(Intent intent) {
        super.onForeground(intent);
    }
    //初始化图片选择列表
    public List<Integer> getImageList() {
        List<Integer> lst = new ArrayList<>();
        lst.add(ResourceTable.Media_md_0);
        lst.add(ResourceTable.Media_md_1);
        lst.add(ResourceTable.Media_md_2);
        lst.add(ResourceTable.Media_md_3);
        lst.add(ResourceTable.Media_md_4);
        lst.add(ResourceTable.Media_md_5);
        lst.add(ResourceTable.Media_md_6);
        return lst;
    }
    //初始化边框选择列表
    public List<Integer> getImageList_1() {
        List<Integer> lst = new ArrayList<>();
        lst.add(ResourceTable.Media_k0);
        lst.add(ResourceTable.Media_k1);
        lst.add(ResourceTable.Media_k2);
        lst.add(ResourceTable.Media_k3);
        lst.add(ResourceTable.Media_k4);
        return lst;
    }

    @Override
    public void onClick(Component component) {
        if(component.getId()==ResourceTable.Id_begin)
            start_game();
        else if(component.getId()==ResourceTable.Id_select)
            Select();
        else if(component.getId()==ResourceTable.Id_xiangce)
            select_pic();
        else if(component.getId()==ResourceTable.Id_paizhao)
            take_photo();
    }
    public void start_game(){
        if (row_n == -1 || col_m == -1) {//这里提示用户开始游戏前应先选择游戏难度(划分规格)
            ToastDialog td = new ToastDialog(getContext());
            td.setText("请先选择游戏难度!");
            td.setAutoClosable(true);
            td.show();
        } else {
            //将用户选择的行数、列数、图片以及边框传递给DynamicPageSlice(用于图片切分与显示等)
            Intent in1 = new Intent();
            AbilitySlice slice = new DynamicPageSlice();
            in1.setParam("row_n", row_n);
            in1.setParam("col_m", col_m);
            in1.setParam("back_src",back_src);
            in1.setParam("img_src", cur_src);
            present(slice, in1);
        }
    }
    public void Select() {
        //进入行列数选择列表，这里的大部分代码实质是对页面样式进行美化，其核心部分主要是Picker组件
        CommonDialog cd = new CommonDialog(this);
        cd.setCornerRadius(40);
        cd.setAutoClosable(true);
        DirectionalLayout dl = new DirectionalLayout(this);
        DirectionalLayout ddl1 = new DirectionalLayout(this);
        DirectionalLayout ddl2 = new DirectionalLayout(this);
        DirectionalLayout ddl3 = new DirectionalLayout(this);

        dl.setOrientation(Component.VERTICAL);
        dl.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
        dl.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        dl.setAlignment(LayoutAlignment.CENTER);

        ddl1.setOrientation(Component.HORIZONTAL);
        ddl1.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
        ddl1.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        ddl1.setAlignment(LayoutAlignment.CENTER);

        ddl2.setOrientation(Component.HORIZONTAL);
        ddl2.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
        ddl2.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        ddl2.setAlignment(LayoutAlignment.CENTER);

        ddl3.setOrientation(Component.HORIZONTAL);
        ddl3.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
        ddl3.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        ddl3.setAlignment(LayoutAlignment.CENTER);

        Button row = new Button(this);
        Button col = new Button(this);
        col.setTextSize(50);
        col.setText("列数");
        row.setTextSize(50);
        row.setText("行数");
        row.setMarginLeft(30); col.setMarginLeft(300);
        ddl1.addComponent(row);
        ddl1.addComponent(col);

        //这里用两个Picker组件分别用于行数、列数的选择
        Picker picker = new Picker(this);
        Picker picker2 = new Picker(this);
        picker.setMaxValue(10);
        picker2.setMaxValue(10);
        picker.setMinValue(2);
        picker2.setMinValue(2);
        picker.setNormalTextSize(50);
        picker2.setNormalTextSize(50);
        picker.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        picker2.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        picker.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        picker2.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        picker.setSelectedTextSize(50);
        picker2.setSelectedTextSize(50);
        picker.setMarginLeft(30);
        picker2.setMarginLeft(300);

        ddl2.addComponent(picker);
        ddl2.addComponent(picker2);

        Button ack = new Button(this);
        Button ret = new Button(this);
        ack.setTextSize(50);
        ack.setText("确认");
        ret.setTextSize(50);
        ret.setText("返回");
        ret.setClickedListener(component1 -> {
            row_n = col_m = -1;
            cd.destroy();
        });

        //获得用户选取的行数、列数的值
        ack.setClickedListener(cmp -> {
            row_n = picker.getValue();
            col_m = picker2.getValue();
            cd.destroy();
        });

        ret.setMarginLeft(30);
        ack.setMarginLeft(300);
        ddl3.addComponent(ret);
        ddl3.addComponent(ack);

        dl.addComponent(ddl1);
        dl.addComponent(ddl2);
        dl.addComponent(ddl3);
        cd.setContentCustomComponent(dl);
        cd.show();

    }
    private void select_pic() {
        Intent intent = new Intent();
        Operation opt = new Intent.OperationBuilder()
                .withAction("android.intent.action.GET_CONTENT").build();
        intent.setOperation(opt);
        intent.addFlags(Intent.FLAG_NOT_OHOS_COMPONENT);
        intent.setType("image/*");
        startAbilityForResult(intent, RequestCode);//这里我们默认requestcode为初始值（0）时，代表用户是从相册中获取图片
    }

    private void take_photo() {
        ValuesBucket valuesBucket = new ValuesBucket();
        valuesBucket.putString("relative_path", "DCIM/Camera/");

        valuesBucket.putString(AVStorage.Images.Media.MIME_TYPE, "image/JPEG");
        DataAbilityHelper helper = DataAbilityHelper.creator(getContext());
        try {
            int id = helper.insert(AVStorage.Images.Media.EXTERNAL_DATA_ABILITY_URI, valuesBucket);
            imageUri1 = Uri.appendEncodedPathToUri(AVStorage.Images.Media.EXTERNAL_DATA_ABILITY_URI, String.valueOf(id));
            Intent intent = new Intent();
            Operation operation = new Intent.OperationBuilder()
                    .withAction("android.media.action.IMAGE_CAPTURE")
                    .build();
            intent.setOperation(operation);
            intent.setParam(AVStorage.Images.Media.OUTPUT, imageUri1);
            startAbilityForResult(intent, 1);//这里我们规定requestcode为1时，代表用户是拍照获取图片

        } catch (DataAbilityRemoteException e) {
            e.printStackTrace();
        }

    }
    //select_pic()与take_photo()都需要根据requestCode从onAbilityResult获得返回的对应结果
    protected void onAbilityResult(int requestCode, int resultCode, Intent resultData) {
        if (requestCode == RequestCode) {//即是说玩家选择“从相册中获取”图片
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
                cur.setScaleMode(Image.ScaleMode.STRETCH);
                cur.setPixelMap(px);

            } catch (DataAbilityRemoteException | FileNotFoundException e) {
                throw new RuntimeException(e);
            }finally {
                if(ims !=null){
                    ims.release();
                }
            }

        }else if(requestCode == 1){//即是说玩家选择“拍照获取”图片
            DataAbilityHelper helper = DataAbilityHelper.creator(getContext());
            Uri uri = imageUri1;
            try{
                FileDescriptor fd = helper.openFile(uri,"r");
                ImageSource ims = ImageSource.create(fd,null);
                PixelMap px = ims.createPixelmap(null);
                cur.setScaleMode(Image.ScaleMode.STRETCH);
                cur.setPixelMap(px);
            } catch (DataAbilityRemoteException | FileNotFoundException e) {
                throw new RuntimeException(e);
            }

            ToastDialog td = new ToastDialog(this);
            td.setText("成功");
            td.show();
        }

    }
}

