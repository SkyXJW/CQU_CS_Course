package com.example.calculate24;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.LinearLayoutManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends AppCompatActivity implements View.OnClickListener{
    private ImageView imageView1;
    private Button cal,res;//计算按钮、重置按钮
    public static FrameLayout heartLayout;
    public static FrameLayout clubLayout;
    public static FrameLayout diamondLayout;
    public static FrameLayout spadeLayout;
    private boolean[] b = new boolean[4]; //记录四个slot是否有牌
    private ImageView[] ima = new ImageView[4];//四个ImageView组件
    private ImageView[] chosen = new ImageView[4];//记录四张被选中的卡牌
    private Map<Drawable,Integer> mp = new HashMap<Drawable, Integer>();//存储每张卡牌对应的数值

    public static float density;//屏幕像素
    RecyclerView mRecyclerView;
    MyAdapter mMyAdapter ;
    List<res> mResesList = new ArrayList<>();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        heartLayout=findViewById(R.id.heartlayout);
        clubLayout=findViewById(R.id.clublayout);
        diamondLayout=findViewById(R.id.diamondlayout);
        spadeLayout=findViewById(R.id.spadelayout);
        density = getResources().getDisplayMetrics().density;//获取屏幕像素
        cal = findViewById(R.id.cal);
        cal.setOnClickListener(this);
        res = findViewById(R.id.res);
        res.setOnClickListener(this);
        imageView1=findViewById(R.id.imageView1);
        mRecyclerView = findViewById(R.id.recycler_view);
        //进行初始化
        for(int i=0;i<4;i++) b[i]=false;
        ima[0] = findViewById(R.id.imageView1);
        ima[1] = findViewById(R.id.imageView2);
        ima[2] = findViewById(R.id.imageView3);
        ima[3] = findViewById(R.id.imageView4);
        DataModel.init();

        for(int i=0;i<DataModel.heart.size();i++){
            //dp转换为像素单位
            int widthInPx = Math.round(80 * density);
            int heightInPx = Math.round(100 * density);
            FrameLayout.LayoutParams layoutParams1=new FrameLayout.LayoutParams(widthInPx,heightInPx, Gravity.BOTTOM);
            ImageView imageView14=new ImageView(MainActivity.this);
            imageView14.setImageResource(DataModel.heart.get(i));
            mp.put(imageView14.getDrawable(),i+1);//存储每张卡牌对应的数值
            layoutParams1.leftMargin=i*65;
            imageView14.setLayoutParams(layoutParams1);
            heartLayout.addView(imageView14);
            imageView14.setOnClickListener(this);
        }
        for(int i=0;i<DataModel.club.size();i++){
            //dp转换为像素单位
            int widthInPx = Math.round(80 * density);
            int heightInPx = Math.round(100 * density);
            FrameLayout.LayoutParams layoutParams1=new FrameLayout.LayoutParams(widthInPx,heightInPx, Gravity.BOTTOM);
            ImageView imageView14=new ImageView(MainActivity.this);
            imageView14.setImageResource(DataModel.club.get(i));
            mp.put(imageView14.getDrawable(),i+1);//存储每张卡牌对应的数值
            layoutParams1.leftMargin=i*65;
            imageView14.setLayoutParams(layoutParams1);
            clubLayout.addView(imageView14);
            imageView14.setOnClickListener(this);
        }
        for(int i=0;i<DataModel.diamond.size();i++){
            //dp转换为像素单位
            int widthInPx = Math.round(80 * density);
            int heightInPx = Math.round(100 * density);
            FrameLayout.LayoutParams layoutParams1=new FrameLayout.LayoutParams(widthInPx,heightInPx, Gravity.BOTTOM);
            ImageView imageView14=new ImageView(MainActivity.this);
            imageView14.setImageResource(DataModel.diamond.get(i));
            mp.put(imageView14.getDrawable(),i+1);//存储每张卡牌对应的数值
            layoutParams1.leftMargin=i*65;
            imageView14.setLayoutParams(layoutParams1);
            diamondLayout.addView(imageView14);
            imageView14.setOnClickListener(this);
        }
        for(int i=0;i<DataModel.spade.size();i++){
            //dp转换为像素单位
            int widthInPx = Math.round(80 * density);
            int heightInPx = Math.round(100 * density);
            FrameLayout.LayoutParams layoutParams1=new FrameLayout.LayoutParams(widthInPx,heightInPx, Gravity.BOTTOM);
            ImageView imageView14=new ImageView(MainActivity.this);
            imageView14.setImageResource(DataModel.spade.get(i));
            mp.put(imageView14.getDrawable(),i+1);//存储每张卡牌对应的数值
            layoutParams1.leftMargin=i*65;
            imageView14.setLayoutParams(layoutParams1);
            spadeLayout.addView(imageView14);
            imageView14.setOnClickListener(this);
        }
    }

    @Override
    public void onClick(View view) {
        if(view.getId()==R.id.cal){
            ClearResults();//清除结果
            //计算前，统计玩家是否选满四张牌
            int cnt = 0;
            for(int i=0;i<4;i++)
                if(b[i]) cnt++;
            if(cnt<4){
                Toast.makeText(this, "请选择四张纸牌!", Toast.LENGTH_SHORT).show();
            }else {
                //得到被选中的卡牌数值
                int op1 = mp.get(ima[0].getDrawable());
                int op2 = mp.get(ima[1].getDrawable());
                int op3 = mp.get(ima[2].getDrawable());
                int op4 = mp.get(ima[3].getDrawable());
                Game24 test = new Game24();
                List<String> List = new ArrayList<String>();
                List = test.getResultList(op1, op2, op3, op4);
                if (List.size() > 0) {
                    ShowResults(List);
                }
                else {
                    Toast.makeText(this, "No Result!", Toast.LENGTH_SHORT).show();
                }
            }
        }
        else if(view.getId()==R.id.res){
            ClearResults();//清除结果
            clear();//重置所有卡牌状态
        }
        else {
        action(view);//卡牌被点击，显示到对应位置（可能是选中操作，也可能是撤销操作）
        }
    }

    public void action(View view){
        FrameLayout.LayoutParams layoutParams= (FrameLayout.LayoutParams) view.getLayoutParams();
        int i = layoutParams.bottomMargin;
        if (i<40){
            //从左到右寻找第一个空闲的（没有牌的）imageview
            int t = find_free();
            if(t==-1){
                Toast.makeText(this, "仅能选择四张纸牌!", Toast.LENGTH_SHORT).show();
            }
            else{
            i=40;
            Drawable rid = ((ImageView) view).getDrawable();
            b[t] = true;
            ima[t].setImageDrawable(rid);
            chosen[t] = (ImageView) view;
            }
        }else{
            //寻找需要被撤销选中的纸牌所占据的imageview
            int t = find_tar(view);
            i=0;
            b[t] = false;
            ima[t].setImageResource(R.drawable.ok);
            chosen[t] = null;
        }
        layoutParams.setMargins(layoutParams.leftMargin,layoutParams.topMargin,layoutParams.rightMargin,i);
        view.setLayoutParams(layoutParams);
    }
        //从左到右寻找第一个空闲的（没有牌的）imageview
        public int find_free(){
         int r=-1;
         for(int i=0;i<4;i++)
             if(!b[i]){
                 r=i;
                 break;
               }
          return r;
         }
       //寻找需要被撤销选中的纸牌所占据的imageview
       public int find_tar(View view){
           int r=-1;
           for(int i=0;i<4;i++)
               if(ima[i].getDrawable()==((ImageView) view).getDrawable()){
                   r=i;
                   break;
               }
           return r;
        }
    //重置所有卡牌状态
    public void clear(){
        //清楚结果显示区的内容
        mRecyclerView.setAdapter(null);
        for(int i=0;i<4;i++){
            b[i] = false;
            ima[i].setImageResource(R.drawable.ok);
            //由于玩家可能会在选满4张卡牌前进行重置操作，故需要先判断当前卡槽chosen[i]是否选中，从而再进行重置操作
            if(chosen[i]!=null){
            FrameLayout.LayoutParams layoutParams= (FrameLayout.LayoutParams) chosen[i].getLayoutParams();
            layoutParams.setMargins(layoutParams.leftMargin,layoutParams.topMargin,layoutParams.rightMargin,0);
            chosen[i].setLayoutParams(layoutParams);
            chosen[i] = null;
            }
        }
    }
    //显示结果
    public void ShowResults(List<String> List){
        for (int i = 0; i < List.size(); i++) {
            res reses = new res();
            int t=i+1;
            reses.title = "Solution" +t+": ";
            reses.content = List.get(i);
            mResesList.add(reses);
        }
        mMyAdapter = new MyAdapter();
        mRecyclerView.setAdapter(mMyAdapter);
        LinearLayoutManager layoutManager = new LinearLayoutManager(MainActivity.this);
        mRecyclerView.setLayoutManager(layoutManager);
    }
    //清除结果
    public void ClearResults(){
        mMyAdapter = new MyAdapter();
        mRecyclerView.setAdapter(mMyAdapter);
        LinearLayoutManager layoutManager = new LinearLayoutManager(MainActivity.this);
        mRecyclerView.setLayoutManager(layoutManager);
        mMyAdapter.clearData(mResesList);  //清空上一次结果
        mMyAdapter.notifyDataSetChanged(); // 刷新RecyclerView的显示
    }
    //由于采用滚动列表组件recyclerview来显示结果，故需要先创建一个适配器类MyAdapter来管理RecyclerView的显示。
    // MyAdapter需要继承自RecyclerView.Adapter类，并实现一下必要的方法
    class MyAdapter extends RecyclerView.Adapter<MyViewHoder> {
        @NonNull
        @Override
        public MyViewHoder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = View.inflate(MainActivity.this, R.layout.res_list, null);
            MyViewHoder myViewHoder = new MyViewHoder(view);
            return myViewHoder;
        }
        @Override
        public void onBindViewHolder(@NonNull MyViewHoder holder, int position) {
            res reses = mResesList.get(position);
            holder.mTitleTv.setText(reses.title);
            holder.mTitleContent.setText(reses.content);
        }
        @Override
        public int getItemCount() {
            return mResesList.size();
        }
        public void clearData(List<res> List) {
            List.clear(); // List是存储数据的列表
        }
    }
    class MyViewHoder extends RecyclerView.ViewHolder {
        TextView mTitleTv;
        TextView mTitleContent;

        public MyViewHoder(@NonNull View itemView) {
            super(itemView);
            mTitleTv = itemView.findViewById(R.id.textView);
            mTitleContent = itemView.findViewById(R.id.textView2);
        }
    }
}