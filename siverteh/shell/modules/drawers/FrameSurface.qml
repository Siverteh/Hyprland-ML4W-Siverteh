import "root:/config"
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
        const t=BorderConfig.thickness,r=BorderConfig.rounding,L=bar.implicitWidth,T=t,R=width-t,B=height-t;
        const commands=[];
        function point(x,y){return x.toFixed(3)+","+y.toFixed(3);}
        function move(x,y){commands.push("M"+point(x,y));}
        function line(x,y){commands.push("L"+point(x,y));}
        function quad(cx,cy,x,y){commands.push("Q"+point(cx,cy)+" "+point(x,y));}
        function notch(u,w,d,map) {
            if(w<0.5||d<0.5)return;
            const rr=Math.min(r,w/2,d/2);
            const p=(a,b)=>map(a,b);
            let a=p(u-rr,0);line(a[0],a[1]);
            a=p(u,0);let b=p(u,rr);quad(a[0],a[1],b[0],b[1]);
            a=p(u,d-rr);line(a[0],a[1]);b=p(u+rr,d);a=p(u,d);quad(a[0],a[1],b[0],b[1]);
            a=p(u+w-rr,d);line(a[0],a[1]);b=p(u+w,d-rr);a=p(u+w,d);quad(a[0],a[1],b[0],b[1]);
            a=p(u+w,rr);line(a[0],a[1]);b=p(u+w+rr,0);a=p(u+w,0);quad(a[0],a[1],b[0],b[1]);
        }
        move(0,0);line(width,0);line(width,height);line(0,height);commands.push("Z");
        move(L+r,T);
        const top=[];
        if(panels.dashboard.height>0.5)top.push(panels.dashboard);
        if(panels.popouts.height>0.5&&panels.popouts.width>0.5)top.push(panels.popouts);
        top.sort((a,b)=>a.x-b.x);
        for(const p of top)notch(p.x,p.width,p.height,(u,v)=>[L+u,T+v]);
        const n=panels.notifications;
        let rightStart=T+r;
        if(n.height>0.5){
            line(R-n.width-r,T);quad(R-n.width,T,R-n.width,T+r);
            line(R-n.width,T+n.height-r);quad(R-n.width,T+n.height,R-n.width+r,T+n.height);
            line(R-r,T+n.height);quad(R,T+n.height,R,T+n.height+r);
            rightStart=T+n.height+r;
        }else{line(R-r,T);quad(R,T,R,T+r);}
        const side=panels.session.width>0.5?panels.session:panels.osd;
        if(side.width>0.5&&T+side.y-r>rightStart)notch(side.y,side.height,side.width,(u,v)=>[R-v,T+u]);
        line(R,B-r);quad(R,B,R-r,B);
        const launcher=panels.launcher;
        if(launcher.height>0.5)notch(R-(L+launcher.x+launcher.width),launcher.width,launcher.height,(u,v)=>[R-u,B-v]);
        line(L+r,B);quad(L,B,L,B-r);line(L,T+r);quad(L,T,L+r,T);commands.push("Z");
        return commands.join(" ");
    }
    ShapePath {
        fillColor: BorderConfig.colour
        strokeWidth: -1
        fillRule: ShapePath.OddEvenFill
        PathSvg { path: root.outline() }
    }
}
