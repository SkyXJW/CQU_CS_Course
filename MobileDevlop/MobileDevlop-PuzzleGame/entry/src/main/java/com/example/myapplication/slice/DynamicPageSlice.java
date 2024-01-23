package com.example.myapplication.slice;

import com.example.myapplication.ResourceTable;
import ohos.aafwk.ability.AbilitySlice;
import ohos.aafwk.content.Intent;
import ohos.agp.animation.Animator;
import ohos.agp.animation.AnimatorGroup;
import ohos.agp.animation.AnimatorProperty;
import ohos.agp.components.*;
import ohos.agp.components.element.PixelMapElement;
import ohos.agp.render.Canvas;
import ohos.agp.render.Paint;
import ohos.agp.render.Texture;
import ohos.agp.utils.Color;
import ohos.agp.utils.LayoutAlignment;
import ohos.agp.window.dialog.CommonDialog;
import ohos.global.resource.NotExistException;
import ohos.global.resource.Resource;
import ohos.media.image.PixelMap;
import ohos.media.image.common.ImageInfo;
import ohos.media.image.common.Rect;
import ohos.media.image.common.Size;

import java.io.IOException;
import java.util.Collections;
import java.util.Vector;

public class DynamicPageSlice extends AbilitySlice implements Component.ClickedListener{
    //row_sz、col_sz代表裁剪图片时的规格，即横竖方向上需裁减的长度
    //row、col代表玩家选择的行列数
    //picsz_r、picsz_c代表划分出的小图片的长宽
    int row_sz, col_sz, row, col,picsz_r, picsz_c;
    //back_src代表玩家选择的相框图片在资源中的id，step步数
    int back_src,step = 0;
    Image cur;
    //mp[][]是由划分出的小图片组成的位图数组，pic[][]则是image数组，pos[][]则是当前位置上的图片编号
    PixelMap mp[][];Image pic[][];Integer pos[][];
    TickTimer timer;long startTime = 0, passTime = 0, fg = 0;
    //nowi、nowj代表当前被点击的图片位置，empi、empj代表空闲图片所处位置
    int nowi, nowj, empi, empj;
    //emp则是代表可移动的空闲图片
    Image emp;
    Text sp;//步数
    //退出按钮与重置按钮
    Button btn_exit,btn_res;
    //cur_1则用于当玩家完成拼图时，用于展示的完整图片
    Image cur_1;
    @Override
    public void onStart(Intent intent) {
        super.onStart(intent);
//        super.setUIContent(ResourceTable.Layout_ability_dynamicpage);
        //当前页面整体是一个竖直方向上的线性布局
        DirectionalLayout dl = new DirectionalLayout(this);
        set_background(dl, ResourceTable.Media_third);
        dl.setOrientation(Component.VERTICAL);
        dl.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
        dl.setHeight(ComponentContainer.LayoutConfig.MATCH_PARENT);
        dl.setAlignment(LayoutAlignment.TOP);

        //获取玩家在游戏开始前的选择界面输入的参数，主要包括图片(cur)及其背景(back_src)、将要切分的行数(row_n)与列数(col_n)
        row = intent.getIntParam("row_n", 3);
        col = intent.getIntParam("col_m", 3);
        back_src = intent.getIntParam("back_src",ResourceTable.Media_k0);
        cur = new Image(this);
        cur.setScaleMode(Image.ScaleMode.STRETCH);
        cur.setHeight(AttrHelper.vp2px(300, this));
        cur.setWidth(AttrHelper.vp2px(300, this));
        cur.setBackground((findComponentById(ResourceTable.Id_current)).getBackgroundElement());
        cur.setPadding(50,50,50,50);
        cur.setPixelMap(((Image) findComponentById(ResourceTable.Id_current)).getPixelMap());
        //设置当玩家完成拼图时，用于展示的完整图片cur_1样式
        cur_1 = new Image(this);
        cur_1.setScaleMode(Image.ScaleMode.STRETCH);
        cur_1.setHeight(AttrHelper.vp2px(300, this));
        cur_1.setWidth(AttrHelper.vp2px(310, this));
        cur_1.setBackground((findComponentById(ResourceTable.Id_current)).getBackgroundElement());
        cur_1.setPadding(50,50,50,50);
        cur_1.setPixelMap(((Image) findComponentById(ResourceTable.Id_current)).getPixelMap());

        //初始化部分
        pic = new Image[row + 1][col + 1];
        mp = new PixelMap[row + 1][col + 1];
        pos = new Integer[row + 1][col + 1];
        for (int i = 0; i <= row; ++i)
            for (int j = 0; j <= col; ++j)
                pos[i][j] = -1;
        //按照切分的规格，得到切分后各小图片的size
        picsz_r = (int) 220 / (row);
        picsz_c = (int) 220 / (col);
        //新建一个线性布局，用于展示玩家需要还原的图片
        DirectionalLayout d1 = build_dl(1);
        d1.setMarginLeft(100);
        d1.setMarginTop(30);
        d1.addComponent(cur);
        //新建一个用于显示耗时、步数以及划分规格信息的线性布局
        DirectionalLayout d2 = build_dl(1);
        d2.setMarginTop(30);
        d2.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
        d2.setHeight(130);
        //这里虽然是一个button组件，但实际上仅用于展示一些文本，并不涉及任何点击事件，而采用button组件显示文本的原因主要是为了美化规整
        Button but1 = new Button(this);
        but1.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        but1.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        but1.setText("难度: " + row + "X" + col);
        but1.setTextSize(70);
        but1.setTextColor(Color.WHITE);
        d2.addComponent(but1);
        //设置计时器
        Text txt = new Text(this);
        txt.setText(" 耗时: ");
        txt.setTextSize(70);
        txt.setTextColor(Color.WHITE);
        timer = new TickTimer(this);
        timer.setCountDown(false);
        timer.setTextSize(70);
        timer.setTextColor(Color.WHITE);
        d2.addComponent(txt);
        d2.addComponent(timer);
        //步数
        sp = new Text(this);
        sp.setTextSize(70);
        sp.setText(" 步数: " + step);
        sp.setTextColor(Color.WHITE);
        d2.addComponent(sp);
//        set_back_color(d2, 0, 0, 255);
        dl.addComponent(d1);
        dl.addComponent(d2);
        //按照划分规格，设置每个小图片的长宽以及样式等
        for (int i = 0; i <= row; i++)
            for (int j = 0; j <= col; ++j) {
                pic[i][j] = new Image(this);
                pic[i][j].setWidth(AttrHelper.vp2px(picsz_c, this));
                pic[i][j].setHeight(AttrHelper.vp2px(picsz_c, this));
                pic[i][j].setScaleMode(Image.ScaleMode.STRETCH);

                if (j != 0) pic[i][j].setMarginLeft(10);
                pic[i][j].setMarginTop(10);
                pic[i][j].setPixelMap(ResourceTable.Media_icon);
//                if (i == row - 1) pic[i][j].setMarginBottom(60);
                pic[i][j].setClickedListener(this);
            }
//        pic[row - 1][col].setMarginRight(30);

        //新增一个线性布局，用来显示被切分的图片
        DirectionalLayout nd = build_dl(0);
        nd.setMarginTop(30);
        nd.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
        nd.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        nd.setAlignment(LayoutAlignment.HORIZONTAL_CENTER|LayoutAlignment.VERTICAL_CENTER);
        nd.setBackground((findComponentById(ResourceTable.Id_current)).getBackgroundElement());
//        nd.setPadding(0,0,0,0);
        PixelMap px = cur.getPixelMap();
        //切分并打乱图片
        cut_pic(px);
        //将切分并打乱的图片显示
        for (int i = 0; i < row; ++i) {
            //每一行都是一个水平方向上的线性布局
            DirectionalLayout tmpd = new DirectionalLayout(this);
//            tmpd.setMarginLeft(20);
            tmpd.setOrientation(Component.HORIZONTAL);
            tmpd.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            tmpd.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
            for (int j = 0; j < col; j++)
                tmpd.addComponent(pic[i][j]);
//            if (i == row - 1) tmpd.addComponent(pic[i][col]);
            nd.addComponent(tmpd);
        }
        dl.addComponent(nd);

        //新增一个线性布局，用来装退出游戏button、重新开始button
        DirectionalLayout d3 = new DirectionalLayout(this);
        d3.setMarginTop(30);
        d3.setOrientation(Component.HORIZONTAL);
        d3.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
        d3.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        d3.setAlignment(LayoutAlignment.HORIZONTAL_CENTER);
        //退出游戏按钮btn_exit
        btn_exit = new Button(this);
        btn_exit.setWidth(300);
        btn_exit.setHeight(130);
//        set_back_color(btn_exit,186,255,216);
        btn_exit.setText("退出游戏");
        btn_exit.setTextSize(70);
        btn_exit.setTextColor(Color.WHITE);
        btn_exit.setClickedListener(component -> {
            exit();
        });
        d3.addComponent(btn_exit);

        //重新开始按钮btn_res
        btn_res = new Button(this);
        btn_res.setWidth(300);
        btn_res.setHeight(130);
//        set_back_color(btn_res,186,255,216);
        btn_res.setText("重新开始");
        btn_res.setTextSize(70);
        btn_res.setTextColor(Color.WHITE);
        btn_res.setClickedListener(component -> {
            re_start();
        });
        btn_res.setMarginLeft(20);
        d3.addComponent(btn_res);

        dl.addComponent(d3);
        super.setUIContent(dl);
    }
    public void set_background(Component cmp,int res_id){
        try{
            Resource res = getResourceManager().getResource(res_id);
            PixelMapElement pixelMapElement = new PixelMapElement(res);
            cmp.setBackground(pixelMapElement);
        }catch(IOException e){
            e.printStackTrace();
        }catch(NotExistException e){
            e.printStackTrace();
        }
    }
//    private void set_back_color(Component component, int r, int g, int b) {
//        ShapeElement element = new ShapeElement();
//        element.setShape(ShapeElement.RECTANGLE);
//        element.setCornerRadius(30);
//        element.setRgbColor(new RgbColor(r, g, b));
//        component.setBackground(element);
//    }

    public DirectionalLayout build_dl(int type) {
        DirectionalLayout dl = new DirectionalLayout(this);
        if (type == 0) dl.setOrientation(Component.VERTICAL);
        else dl.setOrientation(Component.HORIZONTAL);
        dl.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        dl.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        dl.setAlignment(LayoutAlignment.CENTER);
        return dl;
    }
    //切分图片
    public void cut_pic(PixelMap pixelMap) {
        ImageInfo info = pixelMap.getImageInfo();
        //初始化位图选项opt，即位图的图片样式，包括size、pixelFormat等
        PixelMap.InitializationOptions opt = new PixelMap.InitializationOptions();
        int w = Math.min(info.size.height, info.size.width);
        opt.size = new Size();
        opt.size.width = opt.size.height = w;
        opt.pixelFormat = info.pixelFormat;
        opt.editable = true;
        //根据指定的划分行列数，计算需裁剪的小图片的长宽
        row_sz = w / row;
        col_sz = w / col;
        //sz用于设置图片上的数字大小
        int sz = Math.max(row_sz, col_sz);
        //分裂图片
        int t = 0;//用于给图片标记数字的辅助
        for (int i = 0; i < row; ++i)
            for (int j = 0; j < col; ++j) {
                //指定裁剪区域
                Rect r1 = new Rect();
                r1.height = row_sz;
                r1.width = col_sz;
                r1.minX = j * col_sz;
                r1.minY = i * row_sz;
                PixelMap tmp = PixelMap.create(pixelMap, r1, opt);
                //给图片标记上数字
                Canvas canvas = new Canvas(new Texture(tmp));
                Paint paint = new Paint();
                paint.setTextSize(sz);
                paint.setColor(Color.RED);
                canvas.drawText(paint, "" + (++t), col_sz*3/2, row_sz*19/10);
                mp[i][j] = tmp;
            }
        random_shuffle();
    }
    //打乱图片
    private void random_shuffle() {
        Vector<Integer> lst = new Vector<>();
        for (int i = 0; i <= row * col - 1; ++i) lst.add(i);
        //由于在切分图片时，已经给各个小图片编号，所以这里可以直接将编号打乱后，再按照打乱的编号顺序，显示出对应的图片排列即可
        Collections.shuffle(lst);
        for (int i = 0; i <= row * col - 1; ++i) {
            pic[i / col][i % col + (i == row * col - 1 ? 1 : 0)].setPixelMap(mp[lst.get(i) / col][lst.get(i) % col]);
            pos[i / col][i % col + (i == row * col - 1 ? 1 : 0)] = lst.get(i);
        }
        //这里我们总选择将最右下角的图片设置为空闲图片emp
        empi = row - 1;
        empj = col - 1;
        emp = pic[empi][empj];
        pic[empi][empj].setPixelMap(back_src);
    }
    //确定当前被点击的图片位置
    public void find(Component component) {
        for (int i = 0; i <= row; ++i)
            for (int j = 0; j <= col; ++j) {
                if (component == pic[i][j]) {
                    nowi = i;
                    nowj = j;
                    return;
                }
            }
    }
    //判断当前被点击的图片与空白图片是否相邻，因为只有与空白图片相邻的，才可以再点击后与空白图片互换
    public boolean check() {
        if (Math.abs(nowi - empi) + Math.abs(nowj - empj) == 1)
            return true;
        return false;
    }
    //更新并显示步数
    private void update() {
        sp.setText(" 步数: " + step);
    }
    //判断是否完成拼图
    private boolean finished() {
        for (int i = 0; i < row; ++i)
            for (int j = 0; j < col; ++j) {
                if(i!=empi||j!=empj)
                   if (pos[i][j] != (i) * col + j) return false;
            }
        return true;
    }
    //平移的动画效果(这里虽然实现了平移的动画效果，但实际运行测试的效果不太理想，故最终采取的是较为稳妥且快捷的旋转动画效果)
    float s_x, f_x, f_y, s_y;
    private void move(Image c1, Image c2) {
        AnimatorProperty p1 = c1.createAnimatorProperty(), p2 = c2.createAnimatorProperty();
        AnimatorGroup ag = new AnimatorGroup();
        ag.setStateChangedListener(new Animator.StateChangedListener() {
            @Override
            public void onStart(Animator animator) {
            }
            @Override
            public void onStop(Animator animator) {
            }
            @Override
            public void onCancel(Animator animator) {
            }
            @Override
            public void onEnd(Animator animator) {
                c1.setContentPositionX(s_x);
                c1.setContentPositionY(s_y);
                c2.setContentPositionX(f_x);
                c2.setContentPositionY(f_y);
                PixelMap pi1 = c1.getPixelMap();
                PixelMap pi2 = c2.getPixelMap();
                c2.setPixelMap(pi1);
                c1.setPixelMap(pi2);
            }
            @Override
            public void onPause(Animator animator) {
            }
            @Override
            public void onResume(Animator animator) {
            }
        });
        ag.setDuration(1000);
        s_x = c1.getContentPositionX();
        s_y = c1.getContentPositionY();
        f_x = c2.getContentPositionX();
        f_y = c2.getContentPositionY();
        int fg = 0;
        if (s_x == f_x) {
            if (nowi < empi) {
                fg = 1;
            }
            if (nowi < empi) {
                p1.moveFromY(f_y).moveToY(f_y + 15 + picsz_r);
                p2.moveFromY(f_y).moveToY(f_y - 15 - picsz_r);
            } else {
                p2.moveFromY(f_y).moveToY(f_y + 15 + picsz_r);
                p1.moveFromY(f_y).moveToY(f_y - 15 - picsz_r);
            }
        } else {
            p1.moveFromX(s_x).moveToX(f_x);
            p2.moveFromX(f_x).moveToX(s_x);
        }
        ag.runParallel(p1, p2);
        ag.start();
    }
    //旋转的动画效果
    private void play(Component component) {
        Component propertyAnimationImage = component;
        AnimatorProperty animator = propertyAnimationImage.createAnimatorProperty();
        propertyAnimationImage.setRotation(0);
        animator.rotate(360);
        animator.setDuration(100);
        animator.setLoopedCount(1);
        animator.start();
    }
    //退出游戏
    public void exit(){
        CommonDialog cd = new CommonDialog(getContext());
        DirectionalLayout dl = build_dl(0);
        dl.setAlignment(LayoutAlignment.CENTER);
        dl.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
        dl.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        Text title = new Text(this);
        title.setText("退出游戏");
        title.setTextSize(50);
        title.setMarginTop(20);
        Text content = new Text(this);
        content.setText("是否确定退出");
        content.setTextSize(50);
        content.setMarginBottom(20);

        Image cur_2 = new Image(this);
        cur_2.setScaleMode(Image.ScaleMode.STRETCH);
        cur_2.setHeight(AttrHelper.vp2px(230, this));
        cur_2.setWidth(AttrHelper.vp2px(200, this));
        cur_2.setPixelMap(ResourceTable.Media_tick1);

        DirectionalLayout d1 = build_dl(1);
        d1.setMarginTop(30);
        d1.setMarginBottom(30);
        d1.addComponent(cur_2);

        dl.addComponent(title);
        dl.addComponent(d1);
        dl.addComponent(content);

        cd.setContentCustomComponent(dl);
        cd.setAlignment(LayoutAlignment.CENTER);
        cd.setButton(0, "是", (iDialog, i) -> {
            cd.destroy();
            terminate();
        });
        cd.setButton(1, "否", (IDialog, i) -> {
            cd.destroy();
        });
        cd.show();
    }
    //重新开始
    public void re_start(){
        CommonDialog cd = new CommonDialog(getContext());
        DirectionalLayout dl = build_dl(0);
        dl.setAlignment(LayoutAlignment.CENTER);
        dl.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
        dl.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);
        Text title = new Text(this);
        title.setText("重新开始");
        title.setTextSize(50);
        title.setMarginTop(20);
        Text content = new Text(this);
        content.setText("当前游戏进度清零,图片顺序重新打乱");
        content.setTextSize(50);
        content.setMarginBottom(20);

        Image cur_3 = new Image(this);
        cur_3.setScaleMode(Image.ScaleMode.STRETCH);
        cur_3.setHeight(AttrHelper.vp2px(230, this));
        cur_3.setWidth(AttrHelper.vp2px(200, this));
        cur_3.setPixelMap(ResourceTable.Media_tick2);

        DirectionalLayout d1 = build_dl(1);
        d1.setMarginTop(30);
        d1.setMarginBottom(30);
        d1.addComponent(cur_3);

        dl.addComponent(title);
        dl.addComponent(d1);
        dl.addComponent(content);

        cd.setContentCustomComponent(dl);
        cd.setAlignment(LayoutAlignment.CENTER);
        cd.setButton(0, "确定", (iDialog, i) -> {
            //重新开始时，需要重置游戏中的耗时、步数信息，并将图片重新打乱
            startTime = System.currentTimeMillis();
            timer.setBaseTime(startTime- passTime);
            timer.stop(); fg =0;
            step =0;    update();
            random_shuffle();
            cd.destroy();
        });
        cd.setButton(1, "取消", (IDialog, i) -> {
            cd.destroy();
        });
        cd.show();
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
        //fg=0:首次点击图片，则说明游戏开始，启动游戏计时
            if (fg == 0) {
                startTime = System.currentTimeMillis();
                timer.setBaseTime(startTime - passTime);
                timer.start();
                fg = 1;
            }
            //确定当前被点击图片的位置
            find(component);
            //检查是否相邻
            if (check()) {
                ++step;
                update();
                Image img1 = (Image) component;
                Image img2 = emp;
                PixelMap p1 = img1.getPixelMap();
                PixelMap p2 = img2.getPixelMap();
                {
                    Integer tmp = pos[nowi][nowj];
                    pos[nowi][nowj] = pos[empi][empj];
                    pos[empi][empj] = tmp;
                    emp = img1;
                    empi = nowi;
                    empj = nowj;
                }

                if (finished()) {
                    double t = (System.currentTimeMillis() - startTime) / 1000.0;
                    String s = t + "";
                    timer.stop();
                    CommonDialog cd = new CommonDialog(getContext());
                    DirectionalLayout dl = build_dl(0);
                    dl.setAlignment(LayoutAlignment.CENTER);
                    dl.setWidth(ComponentContainer.LayoutConfig.MATCH_PARENT);
                    dl.setHeight(ComponentContainer.LayoutConfig.MATCH_CONTENT);

                    Text title = new Text(this);
                    title.setText("恭喜完成拼图!");
                    title.setTextSize(50);
                    title.setMarginTop(20);
                    Text content = new Text(this);
                    content.setText("耗时: " + s + "s " +
                            "步数: " + step + "步");
                    content.setTextSize(50);
                    content.setMarginBottom(20);
//                    content.setMultipleLine(true);
//                    content.setMaxTextLines(4);

                    DirectionalLayout d1 = build_dl(1);
                    d1.setMarginTop(30);
                    d1.setMarginBottom(30);
                    d1.addComponent(cur_1);
                    cd.setButton(0, "返回主界面", (iDialog, i) -> {
                        cd.destroy();
                        d1.removeComponent(cur_1);
                        terminate();
                    });
                    cd.setButton(1, "继续新游戏", (IDialog, i) -> {
                        cd.destroy();
                        d1.removeComponent(cur_1);
                        startTime = System.currentTimeMillis();
                        timer.setBaseTime(startTime- passTime);
                        timer.stop(); fg =0;
                        step =0;    update();
                        random_shuffle();
                    });
//                    Button but = new Button(this);
//                    but.setText("点击返回");
//                    but.setWidth(ComponentContainer.LayoutConfig.MATCH_CONTENT);
//                    but.setTextSize(50);
//                    but.setClickedListener(component1 -> {
//                        cd.destroy();
//                        terminate();
//                    });

                    dl.addComponent(title);
                    dl.addComponent(d1);
                    dl.addComponent(content);
                    cd.setContentCustomComponent(dl);
                    cd.show();
                }
//            move(img1, img2);
//            if (picker.getValue() == 1) {
//                move(img1, img2);
//            } else {
                play(img1);
                play(img2);
                img1.setPixelMap(p2);
                img2.setPixelMap(p1);
//            }
//            emp = img1;
//            empi = nowi;
//            empj = nowj;
            }
    }
}
