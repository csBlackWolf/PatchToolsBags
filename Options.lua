local _,Bags=...
function Bags:BuildOptions(parent)
    local title=self:Text(parent,"PatchToolsBags · 0.1.2-alpha.2",16); title:SetPoint("TOPLEFT",0,-5)
    local intro=self:Text(parent,self:T("Shared carried bags. Alpha prototype — please report unexpected behavior.","Gemeinsame mitgeführte Taschen. Alpha-Prototyp – unerwartetes Verhalten bitte melden."),12)
    intro:SetPoint("TOPLEFT",0,-43); intro:SetWidth(560); intro:SetJustifyH("LEFT")
    local function Check(y,en,de,key)
        local b=CreateFrame("CheckButton",nil,parent,"UICheckButtonTemplate")
        b:SetPoint("TOPLEFT",0,y); b:SetChecked(Bags.db[key])
        local label=Bags:Text(b,Bags:T(en,de),13); label:SetPoint("LEFT",b,"RIGHT",4,0)
        b:SetScript("OnClick",function()
            Bags.db[key]=b:GetChecked() and true or false
            if Bags.UpdateBankReplacement and (key=="replaceBank" or key=="replaceBags") then Bags:UpdateBankReplacement() end
            Bags:QueueRefresh()
        end)
    end
    Check(-90,"Replace the standard bag window","Standard-Taschenfenster ersetzen","replaceBags")
    Check(-126,"Use the compact bank window at the banker","Kompaktes Bankfenster beim Bankier verwenden","replaceBank")
    local hint=self:Text(parent,self:T("Other bag addons take priority while enabled. /ptbags always opens this window.","Andere aktive Taschen-Addons haben Vorrang. /ptbags öffnet dieses Fenster jederzeit."),12)
    hint:SetPoint("TOPLEFT",36,-161); hint:SetWidth(510); hint:SetJustifyH("LEFT")
    Check(-208,"Show quest, protection and sale markers","Quest-, Schutz- und Verkaufsmarkierungen anzeigen","markers")
    Check(-243,"Show Pawn upgrade arrows","Pawn-Verbesserungen anzeigen","pawnUpgrades")
    local function Slider(y,en,de,key,lo,hi,step)
        local settings=(key=="scale" or key=="columns") and Bags.windowDB or Bags.db
        local label=Bags:Text(parent,"",13); label:SetPoint("TOPLEFT",0,y)
        local slider=CreateFrame("Slider","PatchToolsBagsOption"..key,parent,"OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT",0,y-30); slider:SetWidth(440)
        slider:SetMinMaxValues(lo,hi); slider:SetValueStep(step); slider:SetObeyStepOnDrag(true)
        _G[slider:GetName().."Low"]:SetText(tostring(lo)); _G[slider:GetName().."High"]:SetText(tostring(hi))
        slider:SetScript("OnValueChanged",function(_,value)
            value=math.floor(value/step+0.5)*step
            settings[key]=value
            label:SetText(Bags:T(en,de)..": "..((key=="scale" or key=="backgroundTransparency") and math.floor(value*100+0.5).."%" or tostring(value)))
            Bags:QueueRefresh()
        end)
        slider:SetValue(settings[key])
    end
    Slider(-280,"Bag window scale","Taschenfensterskalierung","scale",0.65,1.3,0.05)
    Slider(-350,"Bag columns","Taschenspalten","columns",6,16,1)
    Slider(-420,"Background transparency (bags and bank)","Hintergrundtransparenz (Taschen und Bank)","backgroundTransparency",0,0.8,0.01)
    local reset=self:Button(parent,self:T("Reset position and size","Position und Größe zurücksetzen"),300,function()
        self.windowDB.x=nil; self.windowDB.y=nil; self.windowDB.scale=1; self.windowDB.columns=10
        self:ResetBankWindow()
        PatchToolsBagsOptionscale:SetValue(1)
        PatchToolsBagsOptioncolumns:SetValue(10)
        self:CreateWindow(); self:PlaceWindow(); self:QueueRefresh()
    end)
    reset:SetPoint("TOPLEFT",0,-490)
    local note=self:Text(parent,self:T("Drag the title to move; drag the lower right corner to scale. Reset: /ptbags reset\nSort orders the display and merges partial stacks; manual placement is retained. Quest and protected items are never marked for sale.","Titelleiste ziehen: verschieben. Ecke unten rechts ziehen: skalieren. Reset: /ptbags reset\nSortieren ordnet die Anzeige und führt Teilstapel zusammen. Manuelle Plätze bleiben bestehen. Questitems und geschützte Items erhalten keine Verkaufsmarkierung."),12)
    note:SetPoint("TOPLEFT",0,-530); note:SetWidth(560); note:SetJustifyH("LEFT")
end
