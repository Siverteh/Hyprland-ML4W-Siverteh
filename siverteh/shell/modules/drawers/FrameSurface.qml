import qs.config
import QtQuick
import QtQuick.Shapes

// One silhouette: an outer surface minus the desktop opening and its panel notches.
Shape {
    id: root
    required property Panels panels
    required property Item bar
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer
    function outline() {
        const r=BorderConfig.rounding,L=bar.implicitWidth,T=panels.y,R=width-BorderConfig.right,B=height-BorderConfig.bottom;
        const tl=L>0&&BorderConfig.headerHeight>0?r:0,tr=BorderConfig.right>0&&BorderConfig.headerHeight>0?r:0;
        const bl=L>0&&BorderConfig.bottom>0?r:0,br=BorderConfig.right>0&&BorderConfig.bottom>0?r:0;
        const commands=[];
        function point(x,y){return x.toFixed(3)+","+y.toFixed(3);}
        function move(x,y){commands.push("M"+point(x,y));}
        function line(x,y){commands.push("L"+point(x,y));}
        function quad(cx,cy,x,y){commands.push("Q"+point(cx,cy)+" "+point(x,y));}
        function notch(u,w,d,map) {
            if(w<0.01||d<0.01)return;
            const rr=Math.min(r,w/2), ry=Math.min(r,d/2);
            const p=(a,b)=>map(a,b);
            let a=p(u-rr,0);line(a[0],a[1]);
            a=p(u,0);let b=p(u,ry);quad(a[0],a[1],b[0],b[1]);
            a=p(u,d-ry);line(a[0],a[1]);b=p(u+rr,d);a=p(u,d);quad(a[0],a[1],b[0],b[1]);
            a=p(u+w-rr,d);line(a[0],a[1]);b=p(u+w,d-ry);a=p(u+w,d);quad(a[0],a[1],b[0],b[1]);
            a=p(u+w,ry);line(a[0],a[1]);b=p(u+w+rr,0);a=p(u+w,0);quad(a[0],a[1],b[0],b[1]);
        }
        move(0,0);line(width,0);line(width,height);line(0,height);commands.push("Z");
        move(L+tl,T);
        const top=[];
        if(panels.dashboard.height>0.5)top.push(panels.dashboard);
        if(panels.popouts.height>0.5&&panels.popouts.width>0.5&&!panels.popouts.joinsRight)top.push(panels.popouts);
        top.sort((a,b)=>a.x-b.x);
        for(const p of top)notch(p.x,p.width,p.height,(u,v)=>[L+u,T+v]);
        const n=panels.popouts.joinsRight&&panels.popouts.height>0.01&&panels.popouts.width>0.01 ? panels.popouts : panels.notifications;
        let rightStart=T+r;
        if(n.height>0.01){
            const ry=Math.min(r,n.height/2);
            line(R-n.width-r,T);quad(R-n.width,T,R-n.width,T+ry);
            line(R-n.width,T+n.height-ry);quad(R-n.width,T+n.height,R-n.width+r,T+n.height);
            line(R-r,T+n.height);quad(R,T+n.height,R,T+n.height+r);
            rightStart=T+n.height+r;
        }else{line(R-tr,T);quad(R,T,R,T+tr);}
        const side=panels.session.width>0.5?panels.session:panels.osd;
        if(side.width>0.5&&T+side.y-r>rightStart)notch(side.y,side.height,side.width,(u,v)=>[R-v,T+u]);
        line(R,B-br);quad(R,B,R-br,B);
        const launcher=panels.launcher;
        if(launcher.height>0.5&&!launcher.fullScreenGallery)notch(R-(L+launcher.x+launcher.width),launcher.width,launcher.height,(u,v)=>[R-u,B-v]);
        line(L+bl,B);quad(L,B,L,B-bl);const left=panels.leftDrawer;
        if(left.width>0.5)notch(B-(T+left.y+left.height),left.height,left.width,(u,v)=>[L+v,B-u]);
        line(L,T+tl);quad(L,T,L+tl,T);commands.push("Z");
        return commands.join(" ");
    }
    ShapePath {
        fillColor: BorderConfig.colour
        strokeWidth: -1
        fillRule: ShapePath.OddEvenFill
        PathSvg { path: root.outline() }
    }
}
