import mx.utils.Delegate;
import com.GameInterface.WaypointInterface;
import com.GameInterface.Game.Character;

class com.judgy.odhd.Mod {
	private static var OD_PLAYFIELD_ID:Number = 7670;
	
	private var m_swfRoot:MovieClip;
	private var m_displayInterval:Number = -1;
	private var m_textfield:TextField = undefined;
	
	public static function main(swfRoot:MovieClip) {
		var s_app = new Mod(swfRoot);
		
		swfRoot.onLoad = function() { s_app.Load(); };
		swfRoot.onUnload = function() { s_app.Unload(); };
	}
	
	public function Mod(swfRoot:MovieClip) {
		this.m_swfRoot = swfRoot;
    }
	
	public function Load():Void {
		WaypointInterface.SignalPlayfieldChanged.Connect(SlotPlayfieldChanged, this);
		SlotPlayfieldChanged();
	}
	
	public function OnUnload():Void {	
		WaypointInterface.SignalPlayfieldChanged.Disconnect(SlotPlayfieldChanged, this);
	}
	
	private function SlotPlayfieldChanged():Void {
		var playfield:Number = Character.GetClientCharacter().GetPlayfieldID();
		if (playfield == 0) {
			setTimeout(Delegate.create(this, SlotPlayfieldChanged), 500);
			return;
		}
		
		if (playfield == OD_PLAYFIELD_ID)
			StartDisplay();
		else
			StopDisplay();
	}
	
	private function StartDisplay():Void {
		if (this.m_displayInterval != -1)
			return;
		
		this.m_displayInterval = setInterval(Delegate.create(this, DisplayHealth), 500);
	}
	
	private function StopDisplay():Void {
		if (this.m_displayInterval == -1)
			return;
			
		clearInterval(this.m_displayInterval);
		this.m_displayInterval = -1;
	}
	
	private function DisplayHealth():Void {
		if (!_root.scryprogress)
			return;
		
		var scry:MovieClip = _root.scryprogress;
		var progress:Number = scry.m_CurrentCount / scry.m_MaxCount * 100;
		progress = Math.round(progress * 100) / 100; //round to x.xx%
		
		if (!m_textfield) {
			var format:TextFormat = scry.m_TextField.getTextFormat();
			format.align = "left";
			m_textfield = scry.createTextField("m_ProgressField", scry.getNextHighestDepth(), scry.m_ProgressBar._x, scry.m_TextField._y, 100, 20);
			m_textfield.setNewTextFormat(format);
			m_textfield.embedFonts = true;
		}
		
		m_textfield.text = "" + progress + "%";
	}
}