define([
  "dojo/_base/declare",
  "dojo/_base/lang",
  "dojo/_base/Deferred",
  "dojo/_base/array",
  "dojo/dom",
  "dojo/promise/all",
  "hpcc/ESPWorkunit"
], function (declare, lang, Deferred, arrayUtil, dom, all, ESPWorkunit) {
    var Workunit = declare("Workunit", null, {
        wu: null,

        constructor: function (args) {
            this.inherited(arguments);
            if (args) {
                declare.safeMixin(this, args);
            }
            this.wu = ESPWorkunit.Get(this.Wuid);
        },

        fetchResults: function (resultNames) {
            var deferred = new Deferred()
            var context = this;
            this.wu.getInfo({
                onGetResults: function (results) {
                    var stores = [];
                    var totals = [];
                    arrayUtil.forEach(resultNames, function (item, idx) {
                        var store = context.wu.get("namedResults")[item].getStore();
                        var query = store.query({
                            Start: 0,
                            Count: 1
                        });
                        var total = query.total;
                        stores.push(store);
                        totals.push(total);
                    });
                    all(totals).then(function (totals) {
                        var queries = [];
                        arrayUtil.forEach(totals, function (item, idx) {
                            var query = stores[idx].query({
                                Start: 0,
                                Count: totals[idx]
                            });
                            queries.push(query);
                        });
                        all(queries).then(function (queries) {
                            var results = [];
                            arrayUtil.forEach(queries, function (item, idx) {
                                results[resultNames[idx]] = item;
                            });
                            deferred.resolve(results);
                        });
                    });
                }
            });
            return deferred.promise;
        }
    });

    return {
        FetchResults: function (wuid, resultNames) {
            var wu = new Workunit({
                Wuid: wuid
            });
            return wu.fetchResults(resultNames);
        },
	Find: function(name) {
	    var wuStore = ESPWorkunit.CreateWUQueryStore();
	    return wuStore.query({
		Jobname: name
	    });
	}
    };
});
