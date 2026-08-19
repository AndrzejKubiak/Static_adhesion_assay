macro "Static adhesion simple Bio-Formats" {

    // =========================
    // USTAW RECZNIE
    // =========================
    inputDir  = "D:\\Static_adhesion_assay\\static_exported\\IET_J\\";
    outputDir = "D:\\Static_adhesion_assay\\static_exported\\IET_J\\results_iet_J\\";
    groupName = "JCD31";
    // =========================

    File.makeDirectory(outputDir);

    resultsFile = outputDir + groupName + "_results_all.csv";
    summaryFile = outputDir + groupName + "_summary.csv";

    if (!File.exists(resultsFile)) {
        File.saveString("Image,Particle,Area,Perim,Circ,AR,Round,Solidity,Feret,MinFeret,Angle\n", resultsFile);
    }

    if (!File.exists(summaryFile)) {
        File.saveString("Image,Particles,MeanArea,TotalArea,MeanPerim,MeanCirc,MeanAR,MeanRound,MeanSolidity,MeanFeret,MeanMinFeret,MeanAngle\n", summaryFile);
    }

    list = getFileList(inputDir);

    for (i = 0; i < list.length; i++) {

        name = list[i];
        path = inputDir + name;

        isTiff =
            endsWith(name, ".tif") ||
            endsWith(name, ".tiff") ||
            endsWith(name, ".TIF") ||
            endsWith(name, ".TIFF");

        correctGroup = indexOf(name, groupName) != -1;

        if (isTiff && correctGroup) {

            print("Analiza: " + name);

            run("Bio-Formats Windowless Importer", "open=[" + path + "]");

            run("Subtract Background...", "rolling=50 sliding");
            setAutoThreshold("Default dark no-reset");
            setOption("BlackBackground", true);
            run("Convert to Mask");
            run("Watershed");

            makeOval(600, 216, 13344, 12552);
            run("Clear Outside");

            run("Set Measurements...", "area perimeter shape feret's redirect=None decimal=3");
            run("Clear Results");

            run("Analyze Particles...", "size=40-1000 circularity=0.10-1.00 display exclude clear include summarize overlay");

            n = nResults;

            sumArea = 0;
            sumPerim = 0;
            sumCirc = 0;
            sumAR = 0;
            sumRound = 0;
            sumSolidity = 0;
            sumFeret = 0;
            sumMinFeret = 0;
            sumAngle = 0;

            for (r = 0; r < n; r++) {

                area      = getResult("Area", r);
                perim     = getResult("Perim.", r);
                circ      = getResult("Circ.", r);
                ar        = getResult("AR", r);
                roundness = getResult("Round", r);
                solidity  = getResult("Solidity", r);
                feret     = getResult("Feret", r);
                minFeret  = getResult("MinFeret", r);
                angle     = getResult("Angle", r);

                sumArea     += area;
                sumPerim    += perim;
                sumCirc     += circ;
                sumAR       += ar;
                sumRound    += roundness;
                sumSolidity += solidity;
                sumFeret    += feret;
                sumMinFeret += minFeret;
                sumAngle    += angle;

                line =
                    name + "," +
                    (r+1) + "," +
                    d2s(area, 3) + "," +
                    d2s(perim, 3) + "," +
                    d2s(circ, 3) + "," +
                    d2s(ar, 3) + "," +
                    d2s(roundness, 3) + "," +
                    d2s(solidity, 3) + "," +
                    d2s(feret, 3) + "," +
                    d2s(minFeret, 3) + "," +
                    d2s(angle, 3) + "\n";

                File.append(line, resultsFile);
            }

            if (n > 0) {
                meanArea     = sumArea / n;
                meanPerim    = sumPerim / n;
                meanCirc     = sumCirc / n;
                meanAR       = sumAR / n;
                meanRound    = sumRound / n;
                meanSolidity = sumSolidity / n;
                meanFeret    = sumFeret / n;
                meanMinFeret = sumMinFeret / n;
                meanAngle    = sumAngle / n;
            } else {
                meanArea     = 0;
                meanPerim    = 0;
                meanCirc     = 0;
                meanAR       = 0;
                meanRound    = 0;
                meanSolidity = 0;
                meanFeret    = 0;
                meanMinFeret = 0;
                meanAngle    = 0;
            }

            summaryLine =
                name + "," +
                n + "," +
                d2s(meanArea, 3) + "," +
                d2s(sumArea, 3) + "," +
                d2s(meanPerim, 3) + "," +
                d2s(meanCirc, 3) + "," +
                d2s(meanAR, 3) + "," +
                d2s(meanRound, 3) + "," +
                d2s(meanSolidity, 3) + "," +
                d2s(meanFeret, 3) + "," +
                d2s(meanMinFeret, 3) + "," +
                d2s(meanAngle, 3) + "\n";

            File.append(summaryLine, summaryFile);

            close();
            run("Clear Results");
        }
    }

    print("Gotowe.");
}