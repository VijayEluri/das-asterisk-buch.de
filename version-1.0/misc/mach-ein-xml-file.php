#!/usr/bin/php5
<?php
// Siehe hilfe
$options = getopt('b:d:efhlo:rp:s:uvz');

// Grundeinstellungen. Wenn $dir nicht gesetzt wird, dann
// das aktuelle Verzeichniss. xy ist fuer die auswahl spaeter,
// 0=string nicht einfuegen, 1=string einfuegen.
$dir    = "yuhu";
$user   = "";
$pass   = "";
$xy     = 0;
$string = "yyy123yyysw";
$output = "singel.xml";
$zahl   = 0;

// Ausgabe der Hilfe und exit, egal was sonst noch angegeben ist.
if ( array_key_exists('h',$options)){
    $hilfe = "
    Optionen;
    ========;

    -h                 diese Hilfe
    -r                 schon existierende Arbeitskopie benutzen
    -b BENUTZER        anderer benutzer zum auschecken als anonymous
    -p PASSWORD        password gleich mit angeben
    -d DIRECTORY       default: yuhu
                       - wenn nicht angegeben, wird in diese verzeichniss verwendet
                       - ansonsten wird die Arbeitskopie in diesem verzeichniss verwendet (bei -r)
                       - wenn noch ausgecheckt wird, so erst in dieses verzeichniss
    -u                 update der Arbeitskopie, funktioniert nur wenn -r angegeben ist
    -s STRING          angabe des strings der hinten dran geschrieben werden soll
    -e                 keinen einfuegen des besonderen zeilenendestrings
    -z                 keinen single file am ende erzeugen
    -o DATEIOUT        singel file in diese datei schreiben, default: singel.xml
    -v                 führt eine validierung der quelle-dateien aus
    -l                 löscht am ende nicht die veränderten quellen
    -f                 keine Ersetzung von <footnote> nach <Footnote> (auch End-Tag)

";
    print ($hilfe);
    exit;
}

// Wenn d angegeben ist, ueberschreibe den Pfad mit dem
// angegebenen Verzeichniss.
if ( array_key_exists('d',$options)){
    $dir = $options['d'];
}
// soll es in was anderes geschrieben werden als in single.xml
// wird eh ignoriert bei -z
if ( array_key_exists('o',$options)){
    $output = $options['o'];
}
// anderer linending string???
// default = yyy123yyysw
if ( array_key_exists('s',$options)){
    $string = $options['s'];
}
// fuer das abholen aus dem repository,
// username und password kann man angeben
if ( array_key_exists('b',$options)){
    $user = "--username " . $options['b'];
}
if ( array_key_exists('p',$options)){
    $pass = "--password " . $options['p'];
}
// abholen aus dem repo, wenn r NICHT gesezt ist, also immer
// ausser wenn man explizit das vorhandene repo benutzen will
if ( !array_key_exists('r',$options)){
    passthru ("rm -rf $dir; svn co $user $pass https://svn.amooma.com/das-asterisk-buch/docbook/ $dir");
}

// vollen pfad ermitteln
$pathnow = realpath(".");
// reinwechseln ins wunschdir
chdir($dir);

if ( $pathnow == realpath($dir) ){
    $options['l'] = "";
}

// wird eine vorhandene Arbeitskopie benutzt, dann kann sie auch geupdated werden
// natuerlich muss man vorher auch drin sein. Benutzer und Passowrd braucht man dann nicht.
if ( array_key_exists('r',$options) and array_key_exists('u',$options)){
    passthru ("rm *xml;svn update");
}

// FALLS e NICHT gesetz ist, ansonsten wird eben kein string eingefuegt
if ( !array_key_exists('e',$options)){

// einlesen der directory-liste. alle xml files, die auch nicht bak oder ~
// oder so heissen werden eingelesen.
        if ($dh = opendir("./")) {
            while (($file = readdir($dh)) !== false) {
                if (preg_match("/xml$/", $file)) {
                    $filename[] = $file;
                }
            }
            closedir($dh);
        }
// erstmal wird ein backup angelegt, in das die alte datei reingeschrieben wird
        foreach ($filename as $value){
        $bak = $value . ".bak";
        copy ($value, $bak);
        $write = fopen ($value, "w");
        $read = fopen ($bak, "r");

// dann wird das backup zeile fuer zeile eingelesen
        while (!feof($read)) {
            $buffer = fgets($read);
            if ( !array_key_exists('f',$options)){            
                if(strstr($buffer, '<footnote>')){
                    $buffer = str_replace("<footnote>", "<Footnote>", $buffer);
                }
                if(strstr($buffer, '</footnote>')){
                    $buffer = str_replace("</footnote>", "</Footnote>", $buffer);
                }
            }
// treffen wir auf den anfangspunkt, fangen wor an, alles zeilenweise in
// ein array zu schreiben, damit wir es nach herzenslust manipulieren koennen
            if (strstr($buffer, '<screen>') or (strstr($buffer, '<programlisting>'))){
                $xy = 1;
            }
            if (strstr($buffer, '</screen>') or (strstr($buffer, '</programlisting>'))){
                $zahl += 1;
                $input[$zahl] = $buffer;
                // jetzt wird sortiert ...
                ksort ($input); // bloss kein risiko eingehen...
                foreach ($input as $key => $val) {
                    if (isset($input[$key+1])) {
                        if (!preg_match('/>$/', $val) and !preg_match('/^</',$input[$key+1])) { 
                            $buffer = ereg_replace("\n", "$string\n", $val);
                            fwrite ($write, $buffer);
                        } else { 
                            fwrite ($write, $val);
                        } 
                    } else { 
                        fwrite ($write, $val); 
                    }
                }
                $xy = 0;
                unset($input);
                $buffer = "";
            }
            if ($xy == 1) {
                // Warum einen zaehler? weil wir ganz sicher sein wollen
                // wir brauchen die exakte reihenfolge ...
                $zahl += 1;
                $input[$zahl] = $buffer;
            }
            if ($xy == 0) {
                fwrite ($write, $buffer); 
            }
        }
        fclose ($write);
        fclose ($read);
        unlink ($bak);
    }
}

// überprüft, ob der source (noch) valid ist
if ( array_key_exists('v',$options)){
    print("Führe validierung durch.\n");
    passthru("xmllint --xinclude --noout das-asterisk-buch.xml");
//        or die("Source ist nicht valid\n");
    
}


// wenn erwuenscht (default) wird der single file erzeugt
if ( !array_key_exists('z',$options)){
    passthru("xmllint --xinclude das-asterisk-buch.xml > $pathnow/$output");
}

// Wir wechseln eins hoch zum loeschen
chdir("..");

// wenn erwuenscht, wird am ende nicht geloescht
$delete = "Konnte/Habe Arbeitskopie nicht löschen...\n";
if ( !array_key_exists('l',$options)){
    passthru("rm -rf $dir");
    $delete = "";
}

if ( !array_key_exists('z',$options)){
    print ("Ihre Datei liegt unter $pathnow/$output\n");
}
print ("$delete");

exit;
